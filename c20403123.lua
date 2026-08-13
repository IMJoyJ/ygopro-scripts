--EMスライハンド・マジシャン
-- 效果：
-- ①：这张卡可以把灵摆怪兽以外的自己场上1只「娱乐伙伴」怪兽解放从手卡特殊召唤。
-- ②：1回合1次，丢弃1张手卡，以场上1张表侧表示的卡为对象才能发动。那张卡破坏。
function c20403123.initial_effect(c)
	-- ①：这张卡可以把灵摆怪兽以外的自己场上1只「娱乐伙伴」怪兽解放从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_HAND)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetCondition(c20403123.hspcon)
	e1:SetTarget(c20403123.hsptg)
	e1:SetOperation(c20403123.hspop)
	c:RegisterEffect(e1)
	-- ②：1回合1次，丢弃1张手卡，以场上1张表侧表示的卡为对象才能发动。那张卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(20403123,0))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCost(c20403123.descost)
	e2:SetTarget(c20403123.destg)
	e2:SetOperation(c20403123.desop)
	c:RegisterEffect(e2)
end
-- 定义hspfilter筛选函数：用于①效果选择可解放的怪兽，要求是属于「娱乐伙伴」且不是灵摆怪兽，解放后自己怪兽区有空位，且该卡是自己场上可供解放的怪兽（控制者为自己或表侧表示）。
function c20403123.hspfilter(c,tp)
	return c:IsSetCard(0x9f) and not c:IsType(TYPE_PENDULUM)
		-- 补充解放条件：解放该卡后我方主要怪兽区仍有空位；且该卡的控制者是我方或是表侧表示，以保证是可解放的己方怪兽。
		and Duel.GetMZoneCount(tp,c)>0 and (c:IsControler(tp) or c:IsFaceup())
end
-- 作为①效果的特殊召唤规则的条件：当系统以c=nil询问能否时返回true；否则检查玩家tp能否从场上找到至少1只满足hspfilter的怪兽用于解放，以从手卡特殊召唤这张卡。
function c20403123.hspcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 用CheckReleaseGroupEx检查玩家tp的场上（不包含手卡）是否存在至少1张满足hspfilter的可解放怪兽，作为特殊召唤手续是否可行的判定。
	return Duel.CheckReleaseGroupEx(tp,c20403123.hspfilter,1,REASON_SPSUMMON,false,nil,tp)
end
-- 在①效果的特殊召唤手续中，从可解放的候选怪兽组里选择1只要解放的怪兽；选择成功则存入e的LabelObject并返回true，否则返回false。
function c20403123.hsptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取玩家tp场上（不包含手卡）可解放的怪兽组，并过滤出满足hspfilter条件的候选怪兽组，供玩家选择解放。
	local g=Duel.GetReleaseGroup(tp,false,REASON_SPSUMMON):Filter(c20403123.hspfilter,nil,tp)
	-- 发送“请选择要解放的卡”的选择提示，让玩家知道需要选择解放怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 执行①效果的特殊召唤手续：将之前选择的怪兽解放，以完成从手卡进行的规则特殊召唤。
function c20403123.hspop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 以特殊召唤为理由（REASON_SPSUMMON）将选择的怪兽解放。
	Duel.Release(g,REASON_SPSUMMON)
end
-- ②效果的发动代价：检查手卡中是否有可丢弃的卡，并实际从手卡丢弃1张卡作为发动代价。
function c20403123.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检测阶段：确认我方手卡至少存在1张可以丢弃的卡，否则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	-- 实际支付代价：从我方手卡选择并丢弃1张卡，丢弃原因标记为COST+REASON_DISCARD。
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 定义破坏对象筛选条件：目标卡必须是表侧表示。
function c20403123.filter(c)
	return c:IsFaceup()
end
-- ②效果的目标选择阶段：选择场上1张表侧表示的卡作为对象，并设置连锁操作信息为破坏该卡。
function c20403123.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and c20403123.filter(chkc) end
	-- 目标检测阶段：确认场上存在至少1张表侧表示且能成为效果对象的卡，否则不能发动。
	if chk==0 then return Duel.IsExistingTarget(c20403123.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 发送“请选择要破坏的卡”的选择提示，让玩家选择对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 从双方场上选择1张表侧表示的卡作为效果对象，并锁定为该连锁的对象。
	local g=Duel.SelectTarget(tp,c20403123.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置当前连锁的操作信息：本次效果将破坏1张对象卡（类别为CATEGORY_DESTROY）。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- ②效果处理：取得对象卡，若该卡仍与效果存在关联，则将其破坏。
function c20403123.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁中获取效果处理时选定的对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 以效果为理由（REASON_EFFECT）将对象卡破坏。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
