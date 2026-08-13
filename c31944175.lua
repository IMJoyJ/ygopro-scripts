--スレッショルド・ボーグ
-- 效果：
-- ①：自己场上没有怪兽存在的场合，这张卡可以把手卡1只电子界族怪兽丢弃，从手卡特殊召唤。
-- ②：只要这张卡在怪兽区域存在，对方场上的怪兽的攻击力下降500。
function c31944175.initial_effect(c)
	-- ①：自己场上没有怪兽存在的场合，这张卡可以把手卡1只电子界族怪兽丢弃，从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c31944175.spcon)
	e1:SetTarget(c31944175.sptg)
	e1:SetOperation(c31944175.spop)
	c:RegisterEffect(e1)
	-- ②：只要这张卡在怪兽区域存在，对方场上的怪兽的攻击力下降500。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetValue(-500)
	c:RegisterEffect(e2)
end
-- 过滤函数：判断手卡中的卡是否为电子界族怪兽，并且可作为丢弃代价被丢弃，用于筛选①效果中满足条件的电子界族怪兽。
function c31944175.cfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsRace(RACE_CYBERSE) and c:IsDiscardable()
end
-- 特殊召唤规则效果的发动条件：若c为nil（规则询问阶段）直接返回true以允许进入选择；否则需确认控制者tp有可用的主要怪兽区空位、自己场上没有怪兽，且手卡中存在除自身外可丢弃的电子界族怪兽。
function c31944175.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 判定控制者tp有可用的主要怪兽区空位，并且自己场上没有怪兽，满足①效果中“自己场上没有怪兽存在的场合”的前提。
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
		-- 继续判定手卡中存在至少1张（除这张卡自身外）满足丢弃条件的电子界族怪兽，作为①效果要丢弃的候选。
		and Duel.IsExistingMatchingCard(c31944175.cfilter,tp,LOCATION_HAND,0,1,c)
end
-- 特殊召唤规则的目标选择处理：筛选出可丢弃的电子界族怪兽候选组，让控制者从中选择1张；选择成功则将该对象存入e的LabelObject并返回true，未选择则返回false。
function c31944175.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取控制者tp手卡中满足丢弃条件的电子界族怪兽候选组，并排除这张卡自身。
	local g=Duel.GetMatchingGroup(c31944175.cfilter,tp,LOCATION_HAND,0,c)
	-- 向控制者tp显示“请选择要丢弃的手牌”的选择提示消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)  --"请选择要丢弃的手牌"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 特殊召唤规则的实际处理：取出目标选择阶段保存的怪兽，将其作为特殊召唤手续丢弃送入墓地，随后由引擎完成这张卡从手卡的特殊召唤。
function c31944175.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将选择的那1张电子界族怪兽从手卡以“特殊召唤手续+丢弃”为原因送入墓地，作为①效果特殊召唤的代价。
	Duel.SendtoGrave(g,REASON_SPSUMMON+REASON_DISCARD)
end
