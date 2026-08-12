--エレキハダマグロ
-- 效果：
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：自己怪兽给与对方战斗伤害的伤害步骤结束时才能发动。这张卡从手卡特殊召唤。
-- ②：这张卡可以直接攻击。
-- ③：这张卡直接攻击给与对方战斗伤害时才能发动。这张卡和除调整以外的自己的手卡·场上（表侧表示）的怪兽1只以上解放，把持有和解放的怪兽的等级合计相同等级的1只「电气」同调怪兽从额外卡组特殊召唤。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数
function s.initial_effect(c)
	-- ②：这张卡可以直接攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_DIRECT_ATTACK)
	c:RegisterEffect(e1)
	-- ①：自己怪兽给与对方战斗伤害的伤害步骤结束时才能发动。这张卡从手卡特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_DAMAGE_STEP_END)
	e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	if not s.global_check then
		s.global_check=true
		-- 自己怪兽给与对方战斗伤害
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e3:SetCode(EVENT_BATTLE_DAMAGE)
		e3:SetCondition(s.regcon)
		e3:SetOperation(s.regop)
		-- 注册全局战斗伤害监听效果
		Duel.RegisterEffect(e3,0)
	end
	-- ③：这张卡直接攻击给与对方战斗伤害时才能发动。这张卡和除调整以外的自己的手卡·场上（表侧表示）的怪兽1只以上解放，把持有和解放的怪兽的等级合计相同等级的1只「电气」同调怪兽从额外卡组特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_RELEASE+CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_BATTLE_DAMAGE)
	e4:SetCountLimit(1,id+o)
	e4:SetCondition(s.sscon)
	e4:SetTarget(s.sstg)
	e4:SetOperation(s.ssop)
	c:RegisterEffect(e4)
end
-- 自己怪兽特殊召唤效果的发动条件检查
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 返回本回合自己是否曾给与对方战斗伤害的标志数量是否大于0
	return Duel.GetFlagEffect(tp,id)>0
end
-- 自己怪兽特殊召唤效果的靶向与可行性检查
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 在效果发动检查时，检查主要怪兽区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤自身的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 自己怪兽特殊召唤效果的效果处理
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 如果此卡依然存在于手卡中，则将其特殊召唤
	if c:IsRelateToEffect(e) then Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP) end
end
-- 检查是否是战斗伤害（伤害接受者不等于伤害造成者）
function s.regcon(e,tp,eg,ep,ev,re,r,rp)
	return ep~=rp
end
-- 记录战斗伤害发生的标记处理
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	-- 为造成伤害的玩家注册本回合已造成战斗伤害的标记
	Duel.RegisterFlagEffect(rp,id,RESET_PHASE+PHASE_DAMAGE,0,1)
end
-- 同调怪兽特殊召唤效果的发动条件：直接攻击给与对方战斗伤害时
function s.sscon(e,tp,eg,ep,ev,re,r,rp)
	-- 返回本次战斗伤害是否由直接攻击造成
	return ep==1-tp and Duel.GetAttackTarget()==nil
end
-- 过滤手卡或场上表侧表示的非调整怪兽
function s.mfilter(c)
	return not c:IsType(TYPE_TUNER) and c:IsFaceupEx() and c:GetLevel()>0
end
-- 过滤可以特殊召唤且等级符合解放怪兽等级合计的「电气」同调怪兽
function s.spfilter(c,e,tp,g)
	return c:IsSetCard(0xe) and c:IsType(TYPE_SYNCHRO) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and g:CheckSubGroup(s.gcheck,1,#g,tp,e:GetHandler(),c)
end
-- 检查解放怪兽的等级合计与额外区域位置是否满足的辅助函数
function s.gcheck(g,tp,ec,sc)
	-- 返回解放所选怪兽后是否能将该同调怪兽特殊召唤，并且它们的等级合计是否等于该同调怪兽的等级
	return Duel.GetLocationCountFromEx(tp,tp,g+ec,sc)>0 and g:GetSum(Card.GetLevel)+ec:GetLevel()==sc:GetLevel()
end
-- 同调怪兽特殊召唤效果的靶向与可行性检查
function s.sstg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 获取自己可解放的、符合非调整怪兽条件的卡片组
	local g=Duel.GetReleaseGroup(tp,true,REASON_EFFECT):Filter(s.mfilter,c)
	if chk==0 then return c:IsReleasableByEffect() and c:GetLevel()>0
		-- 检查额外卡组中是否存在符合条件的可以特殊召唤的「电气」同调怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,g) end
	-- 设置解放怪兽的操作信息
	Duel.SetOperationInfo(0,CATEGORY_RELEASE,g,2,0,0)
end
-- 同调怪兽特殊召唤效果的效果处理
function s.ssop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 在效果处理时再次获取可解放的非调整怪兽组
	local g=Duel.GetReleaseGroup(tp,true,REASON_EFFECT):Filter(s.mfilter,c)
	if not (c:IsRelateToEffect(e) and c:IsReleasableByEffect()) or #g==0 then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家从额外卡组中选择1只「电气」同调怪兽
	local tc=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,g):GetFirst()
	if tc then
		-- 提示玩家选择要解放的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
		local sg=g:SelectSubGroup(tp,s.gcheck,false,1,#g,tp,c,tc)+c
		-- 如果成功解放被选中的怪兽，则特殊召唤该「电气」同调怪兽
		if Duel.Release(sg,REASON_EFFECT)>0 then Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP) end
	end
end
