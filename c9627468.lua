--甲虫合体ゼクスタッガー
-- 效果：
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：昆虫族怪兽特殊召唤的场合才能发动。这张卡从手卡特殊召唤。
-- ②：这张卡的攻击力上升场上的其他的昆虫族怪兽数量×300。
-- ③：自己·对方的结束阶段发动。双方各自可以从自身的手卡·墓地把1只昆虫族怪兽特殊召唤。这个效果特殊召唤的怪兽的效果无效化。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数
function s.initial_effect(c)
	-- ①：昆虫族怪兽特殊召唤的场合才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"这张卡从手卡特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetRange(LOCATION_HAND)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡的攻击力上升场上的其他的昆虫族怪兽数量×300。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(s.atkval)
	c:RegisterEffect(e2)
	-- ③：自己·对方的结束阶段发动。双方各自可以从自身的手卡·墓地把1只昆虫族怪兽特殊召唤。这个效果特殊召唤的怪兽的效果无效化。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_SPSUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id+1)
	e3:SetTarget(s.sptg2)
	e3:SetOperation(s.spop2)
	c:RegisterEffect(e3)
end
-- 过滤场上表侧表示昆虫族怪兽的条件函数
function s.spfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_INSECT)
end
-- 检查是否有昆虫族怪兽特殊召唤成功，作为效果①的发动条件
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.spfilter,1,nil)
end
-- 效果①的发动准备与合法性检测函数
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自身怪兽区域是否有空位，且自身是否可以特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁处理中的操作信息为特殊召唤自身
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果①的处理函数，将自身特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡以表侧表示特殊召唤到发动效果的玩家场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 计算效果②攻击力上升数值的函数
function s.atkval(e,c)
	-- 返回场上除自身以外的表侧表示昆虫族怪兽数量乘以300的数值
	return Duel.GetMatchingGroupCount(s.spfilter,0,LOCATION_MZONE,LOCATION_MZONE,c)*300
end
-- 过滤手卡或墓地中可以特殊召唤的昆虫族怪兽的条件函数
function s.spfilter2(c,e,tp)
	return c:IsRace(RACE_INSECT) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果③的发动准备与合法性检测函数
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
end
-- 效果③的处理函数，双方玩家各自选择是否从手卡或墓地特殊召唤1只昆虫族怪兽
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g1=Group.CreateGroup()
	local g2=Group.CreateGroup()
	-- 检查回合玩家的怪兽区域是否有空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查回合玩家的手卡或墓地是否存在至少1只满足条件的昆虫族怪兽
		and Duel.IsExistingMatchingCard(s.spfilter2,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp)
		-- 询问回合玩家是否选择进行特殊召唤
		and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否选1只昆虫族怪兽特殊召唤？"
		-- 提示回合玩家选择要特殊召唤的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 让回合玩家从自身手卡或墓地选择1只昆虫族怪兽
		g1=Duel.SelectMatchingCard(tp,s.spfilter2,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
	end
	-- 检查非回合玩家的怪兽区域是否有空位
	if Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0
		-- 检查非回合玩家的手卡或墓地是否存在至少1只满足条件的昆虫族怪兽
		and Duel.IsExistingMatchingCard(s.spfilter2,1-tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,1-tp)
		-- 询问非回合玩家是否选择进行特殊召唤
		and Duel.SelectYesNo(1-tp,aux.Stringid(id,2)) then  --"是否选1只昆虫族怪兽特殊召唤？"
		-- 提示非回合玩家选择要特殊召唤的卡片
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 让非回合玩家从自身手卡或墓地选择1只昆虫族怪兽
		g2=Duel.SelectMatchingCard(1-tp,s.spfilter2,1-tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,1-tp)
	end
	if g1:GetCount()>0 then
		local tc=g1:GetFirst()
		-- 将回合玩家选择的怪兽以表侧表示特殊召唤到其场上的分解步骤
		Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
		-- 这个效果特殊召唤的怪兽的效果无效化。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 这个效果特殊召唤的怪兽的效果无效化。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
		-- 完成回合玩家怪兽的特殊召唤流程
		Duel.SpecialSummonComplete()
	end
	if g2:GetCount()>0 then
		local tc=g2:GetFirst()
		-- 将非回合玩家选择的怪兽以表侧表示特殊召唤到其场上的分解步骤
		Duel.SpecialSummonStep(tc,0,1-tp,1-tp,false,false,POS_FACEUP)
		-- 这个效果特殊召唤的怪兽的效果无效化。
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_DISABLE)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e3)
		-- 这个效果特殊召唤的怪兽的效果无效化。
		local e4=Effect.CreateEffect(c)
		e4:SetType(EFFECT_TYPE_SINGLE)
		e4:SetCode(EFFECT_DISABLE_EFFECT)
		e4:SetValue(RESET_TURN_SET)
		e4:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e4)
		-- 完成非回合玩家怪兽的特殊召唤流程
		Duel.SpecialSummonComplete()
	end
end
