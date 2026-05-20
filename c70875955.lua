--空中補給
-- 效果：
-- 这张卡的控制者在每次双方的结束阶段把自己场上1只衍生物或者「幻兽机」怪兽解放。或者都不解放让这张卡送去墓地。
-- ①：1回合1次，可以发动。在自己场上把1只「幻兽机衍生物」（机械族·风·3星·攻/守0）特殊召唤。
function c70875955.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：1回合1次，可以发动。在自己场上把1只「幻兽机衍生物」（机械族·风·3星·攻/守0）特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetDescription(aux.Stringid(70875955,0))  --"特殊召唤Token"
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(0,TIMING_END_PHASE)
	e2:SetCountLimit(1)
	e2:SetTarget(c70875955.sptg)
	e2:SetOperation(c70875955.spop)
	c:RegisterEffect(e2)
	-- 这张卡的控制者在每次双方的结束阶段把自己场上1只衍生物或者「幻兽机」怪兽解放。或者都不解放让这张卡送去墓地。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(70875955,1))  --"是否现在使用「空中补给」的效果？"
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetCountLimit(1)
	e3:SetOperation(c70875955.mtop)
	c:RegisterEffect(e3)
end
-- ①效果（特殊召唤衍生物）的发动准备与合法性检测函数
function c70875955.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段检查自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并检查玩家是否可以特殊召唤指定的「幻兽机衍生物」
		and Duel.IsPlayerCanSpecialSummonMonster(tp,31533705,0x101b,TYPES_TOKEN_MONSTER,0,0,3,RACE_MACHINE,ATTRIBUTE_WIND) end
	-- 设置连锁信息，表示该效果包含产生衍生物的操作
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	-- 设置连锁信息，表示该效果包含特殊召唤怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
-- ①效果（特殊召唤衍生物）的效果处理函数
function c70875955.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 若此时自己场上没有可用的怪兽区域，则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 再次确认玩家是否可以特殊召唤该衍生物
	if Duel.IsPlayerCanSpecialSummonMonster(tp,31533705,0x101b,TYPES_TOKEN_MONSTER,0,0,3,RACE_MACHINE,ATTRIBUTE_WIND) then
		-- 创建「幻兽机衍生物」的卡片数据
		local token=Duel.CreateToken(tp,70875956)
		-- 将创建的衍生物以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤函数：筛选场上的衍生物或者「幻兽机」怪兽
function c70875955.rfilter(c)
	return c:IsType(TYPE_TOKEN) or c:IsSetCard(0x101b)
end
-- 维持代价（结束阶段解放怪兽或送去墓地）的效果处理函数
function c70875955.mtop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在至少1只可作为维持代价解放的衍生物或「幻兽机」怪兽
	if Duel.CheckReleaseGroupEx(tp,c70875955.rfilter,1,REASON_MAINTENANCE,false,nil)
		-- 并询问玩家是否选择解放怪兽以维持该卡
		and Duel.SelectYesNo(tp,aux.Stringid(70875955,2)) then  --"是否要把场上1只衍生物或者名字带有「幻兽机」的怪兽解放维持「空中补给」？"
		-- 让玩家选择1只符合条件的怪兽作为维持代价解放
		local g=Duel.SelectReleaseGroupEx(tp,c70875955.rfilter,1,1,REASON_MAINTENANCE,false,nil)
		-- 解放所选的怪兽
		Duel.Release(g,REASON_MAINTENANCE)
	else
		-- （若不解放怪兽）则根据规则将这张卡送去墓地
		Duel.SendtoGrave(e:GetHandler(),REASON_RULE)
	end
end
