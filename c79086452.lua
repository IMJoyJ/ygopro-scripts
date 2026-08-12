--ギミック・パペット－ビスク・ドール
-- 效果：
-- ①：这张卡可以把手卡1只「机关傀儡」怪兽丢弃，从手卡特殊召唤。
-- ②：把墓地的这张卡除外才能发动。这个回合中，对方不能把自己场上的「机关傀儡」怪兽作为效果的对象。
function c79086452.initial_effect(c)
	-- ①：这张卡可以把手卡1只「机关傀儡」怪兽丢弃，从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(79086452,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c79086452.spcon)
	e1:SetTarget(c79086452.sptg)
	e1:SetOperation(c79086452.spop)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外才能发动。这个回合中，对方不能把自己场上的「机关傀儡」怪兽作为效果的对象。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(79086452,1))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	-- 将墓地的这张卡除外作为发动效果的Cost
	e2:SetCost(aux.bfgcost)
	e2:SetOperation(c79086452.operation)
	c:RegisterEffect(e2)
end
-- 过滤手卡中「机关傀儡」怪兽的条件函数
function c79086452.spfilter(c)
	return c:IsSetCard(0x1083) and c:IsType(TYPE_MONSTER)
end
-- 特殊召唤规则的条件函数，检查怪兽区域空位及手卡中是否存在其他「机关傀儡」怪兽
function c79086452.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查自己场上是否有可用的怪兽区域空位
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡中是否存在除自身以外的「机关傀儡」怪兽
		and Duel.IsExistingMatchingCard(c79086452.spfilter,tp,LOCATION_HAND,0,1,c)
end
-- 特殊召唤规则的目标选择函数，用于选择要丢弃的手卡
function c79086452.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取手卡中除自身以外的所有「机关傀儡」怪兽
	local g=Duel.GetMatchingGroup(c79086452.spfilter,tp,LOCATION_HAND,0,c)
	-- 提示玩家选择要丢弃的手牌
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)  --"请选择要丢弃的手牌"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 特殊召唤规则的操作函数，执行丢弃手牌的处理
function c79086452.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将选中的手牌作为特殊召唤的消耗丢弃送去墓地
	Duel.SendtoGrave(g,REASON_SPSUMMON+REASON_DISCARD)
end
-- 效果②的操作函数，注册一个本回合内使自己场上的「机关傀儡」怪兽不成为对方效果对象的全局效果
function c79086452.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 这个回合中，对方不能把自己场上的「机关傀儡」怪兽作为效果的对象。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(c79086452.efftg)
	-- 设置不能成为对方卡片效果的对象
	e1:SetValue(aux.tgoval)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 向全局环境注册该回合内生效的抗性效果
	Duel.RegisterEffect(e1,tp)
end
-- 过滤受该抗性效果影响的卡片，即自己场上的「机关傀儡」怪兽
function c79086452.efftg(e,c)
	return c:IsSetCard(0x1083)
end
