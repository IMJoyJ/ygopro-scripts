--激動の未界域
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：自己的「未界域」怪兽被和对方怪兽的战斗破坏时才能发动。那只对方怪兽破坏。
-- ②：从自己墓地把「未界域」魔法·陷阱卡3种类各1张除外才能发动。场上的卡全部破坏。这个效果的发动后，直到回合结束时自己不是「未界域」怪兽不能特殊召唤。
function c23213239.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 对应①：自己的「未界域」怪兽被和对方怪兽的战斗破坏时才能发动。那只对方怪兽破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(23213239,0))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_DESTROYED)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCondition(c23213239.bdcon)
	e2:SetTarget(c23213239.bdtg)
	e2:SetOperation(c23213239.bdop)
	c:RegisterEffect(e2)
	-- 对应②：从自己墓地把「未界域」魔法·陷阱卡3种类各1张除外才能发动。场上的卡全部破坏。这个效果的发动后，直到回合结束时自己不是「未界域」怪兽不能特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(23213239,1))
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCountLimit(1,23213239)
	e3:SetCost(c23213239.descost)
	e3:SetTarget(c23213239.destg)
	e3:SetOperation(c23213239.desop)
	c:RegisterEffect(e3)
end
-- 筛选战斗破坏事件中的卡：被战斗破坏的、之前控制者为自己的「未界域」怪兽，且战斗对象是对方怪兽并仍与战斗相关。
function c23213239.cfilter(c,tp)
	local rc=c:GetReasonCard()
	return c:IsReason(REASON_BATTLE) and c:IsPreviousControler(tp) and c:IsSetCard(0x11e)
		and rc and rc:IsControler(1-tp) and rc:IsRelateToBattle()
end
-- ①的发动条件：从战斗破坏的怪兽中找出符合条件的我方未界域怪兽，并把其战斗对象（对方怪兽）记录到效果标签，满足条件才可发动。
function c23213239.bdcon(e,tp,eg,ep,ev,re,r,rp)
	local dc=eg:Filter(c23213239.cfilter,nil,tp):GetFirst()
	if dc then
		e:SetLabelObject(dc:GetReasonCard())
		return true
	else return false end
end
-- ①的发动时处理：检查可发动后通过，并将记录的对方怪兽写入连锁操作信息作为将要破坏的对象。
function c23213239.bdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：将记录的对方战斗怪兽确定为破坏对象，数量为1，用于连锁互动判定。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetLabelObject(),1,0,0)
end
-- ①的效果处理：取出记录的对方怪兽，若它仍与本次战斗相关，则将其破坏。
function c23213239.bdop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc and tc:IsRelateToBattle() then
		-- 以效果原因破坏该对方怪兽。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- 代价筛选：自己墓地的「未界域」魔法·陷阱卡且可以作为除外代价。
function c23213239.costfilter(c)
	return c:IsSetCard(0x11e) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToRemoveAsCost()
end
-- ②的代价处理：先从自己墓地取得符合条件的「未界域」魔法·陷阱卡；检查是否至少有3种；然后提示玩家选择3张卡名互不相同的卡，并将其表侧除外作为发动代价。
function c23213239.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 取得自己墓地的所有「未界域」魔法·陷阱卡作为代价候选组。
	local g=Duel.GetMatchingGroup(c23213239.costfilter,tp,LOCATION_GRAVE,0,nil)
	if chk==0 then return g:GetClassCount(Card.GetCode)>=3 end
	-- 显示选择提示，要求玩家选择要除外的卡（提示信息为HINTMSG_REMOVE）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从候选组中选择3张卡名互不相同的卡，对应『3种类各1张』的要求。
	local rg=g:SelectSubGroup(tp,aux.dncheck,false,3,3)
	-- 将选中的3张卡从墓地以表侧表示除外，作为发动代价。
	Duel.Remove(rg,POS_FACEUP,REASON_COST)
end
-- ②的发动目标：确认场上存在卡时，取得场上全部卡并设置操作信息为将其全部破坏。
function c23213239.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- ②发动合法性判定：场上至少存在1张卡时才能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 取得双方场上所有卡，用于设置连锁操作信息中的破坏对象及数量。
	local g=Duel.GetMatchingGroup(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	-- 设置操作信息：将当前双方场上全部卡作为破坏对象，数量为场上卡的总数。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- ②的效果处理：破坏场上全部卡，并给发动者附加直到回合结束不能特殊召唤非「未界域」怪兽的限制。
function c23213239.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时重新取得当前场上所有卡，确保破坏的是处理时仍存在于场上的卡。
	local g=Duel.GetMatchingGroup(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	-- 以效果原因破坏双方场上的全部卡。
	Duel.Destroy(g,REASON_EFFECT)
	-- 对应效果原文：‘这个效果的发动后，直到回合结束时自己不是「未界域」怪兽不能特殊召唤。’
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c23213239.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将上述特殊召唤限制效果注册给发动者tp，持续到回合结束。
	Duel.RegisterEffect(e1,tp)
end
-- 限制特殊召唤的对象：不是「未界域」怪兽不能特殊召唤。
function c23213239.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsSetCard(0x11e)
end
