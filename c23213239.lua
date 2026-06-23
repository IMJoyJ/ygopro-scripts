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
	-- ①：自己的「未界域」怪兽被和对方怪兽的战斗破坏时才能发动。那只对方怪兽破坏。
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
	-- ②：从自己墓地把「未界域」魔法·陷阱卡3种类各1张除外才能发动。场上的卡全部破坏。这个效果的发动后，直到回合结束时自己不是「未界域」怪兽不能特殊召唤。
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
-- 过滤函数，用于判断被战斗破坏的怪兽是否为我方「未界域」怪兽且是由对方怪兽破坏的
function c23213239.cfilter(c,tp)
	local rc=c:GetReasonCard()
	return c:IsReason(REASON_BATTLE) and c:IsPreviousControler(tp) and c:IsSetCard(0x11e)
		and rc and rc:IsControler(1-tp) and rc:IsRelateToBattle()
end
-- 判断是否有满足条件的被战斗破坏的「未界域」怪兽，若有则将该怪兽的破坏来源怪兽设为标签对象
function c23213239.bdcon(e,tp,eg,ep,ev,re,r,rp)
	local dc=eg:Filter(c23213239.cfilter,nil,tp):GetFirst()
	if dc then
		e:SetLabelObject(dc:GetReasonCard())
		return true
	else return false end
end
-- 设置连锁操作信息，指定要破坏的卡为标签对象
function c23213239.bdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置当前处理的连锁的操作信息，指定要破坏的卡为标签对象
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetLabelObject(),1,0,0)
end
-- 执行效果操作，若标签对象存在且与战斗相关，则将其破坏
function c23213239.bdop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc and tc:IsRelateToBattle() then
		-- 将目标怪兽以效果原因破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- 过滤函数，用于筛选墓地中的「未界域」魔法或陷阱卡
function c23213239.costfilter(c)
	return c:IsSetCard(0x11e) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToRemoveAsCost()
end
-- 设置发动效果的代价，要求从墓地中选择3种不同种类的「未界域」魔法或陷阱卡除外
function c23213239.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取满足条件的墓地中的「未界域」魔法或陷阱卡组
	local g=Duel.GetMatchingGroup(c23213239.costfilter,tp,LOCATION_GRAVE,0,nil)
	if chk==0 then return g:GetClassCount(Card.GetCode)>=3 end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从满足条件的卡组中选择3张不同种类的卡组成除外组
	local rg=g:SelectSubGroup(tp,aux.dncheck,false,3,3)
	-- 将选中的卡以除外形式移除
	Duel.Remove(rg,POS_FACEUP,REASON_COST)
end
-- 设置发动效果的目标，指定场上所有卡为破坏对象
function c23213239.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在至少一张卡
	if chk==0 then return Duel.IsExistingMatchingCard(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 获取场上所有卡的组
	local g=Duel.GetMatchingGroup(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	-- 设置当前处理的连锁的操作信息，指定要破坏的卡为场上所有卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 执行效果操作，将场上所有卡破坏，并设置一个直到回合结束时不能特殊召唤非「未界域」怪兽的效果
function c23213239.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取场上所有卡的组
	local g=Duel.GetMatchingGroup(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	-- 将场上所有卡以效果原因破坏
	Duel.Destroy(g,REASON_EFFECT)
	-- 创建一个直到回合结束时禁止特殊召唤非「未界域」怪兽的效果
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c23213239.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将创建的效果注册给玩家
	Duel.RegisterEffect(e1,tp)
end
-- 限制特殊召唤效果的目标函数，禁止召唤非「未界域」怪兽
function c23213239.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsSetCard(0x11e)
end
