--黄色い忍者
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：这张卡召唤·反转的场合才能发动。从手卡把1只4星以下的「忍者」怪兽表侧攻击表示或者里侧守备表示特殊召唤。这个效果的发动后，直到回合结束时自己不是「忍者」怪兽不能从额外卡组特殊召唤。
function c64749612.initial_effect(c)
	-- ①：这张卡召唤·反转的场合才能发动。从手卡把1只4星以下的「忍者」怪兽表侧攻击表示或者里侧守备表示特殊召唤。这个效果的发动后，直到回合结束时自己不是「忍者」怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(64749612,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_MSET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,64749612)
	e1:SetTarget(c64749612.sptg)
	e1:SetOperation(c64749612.spop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_FLIP)
	c:RegisterEffect(e2)
end
-- 过滤手牌中4星以下的「忍者」怪兽，且该怪兽可以以表侧攻击表示或里侧守备表示特殊召唤
function c64749612.spfilter(c,e,tp)
	return c:IsSetCard(0x2b) and c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK+POS_FACEDOWN_DEFENSE)
end
-- 效果①的发动准备（检查怪兽区域空位以及手牌中是否存在可特殊召唤的怪兽）
function c64749612.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上的怪兽区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手牌中是否存在至少1只满足条件的「忍者」怪兽
		and Duel.IsExistingMatchingCard(c64749612.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置连锁信息，表示该效果包含从手牌特殊召唤1只怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果①的效果处理（注册额外卡组特殊召唤限制，并从手牌特殊召唤怪兽）
function c64749612.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 这个效果的发动后，直到回合结束时自己不是「忍者」怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c64749612.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册该玩家效果，使限制在当前回合内生效
	Duel.RegisterEffect(e1,tp)
	-- 检查怪兽区域是否还有空位，若无则不处理特殊召唤
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<1 then return end
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手牌选择1只满足条件的「忍者」怪兽
	local g=Duel.SelectMatchingCard(tp,c64749612.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc then
		-- 将选择的怪兽以表侧攻击表示或里侧守备表示特殊召唤，并判断是否以里侧守备表示特殊召唤成功
		if Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_ATTACK+POS_FACEDOWN_DEFENSE)~=0 and tc:IsFacedown() then
			-- 给对方玩家确认里侧特殊召唤的怪兽
			Duel.ConfirmCards(1-tp,tc)
		end
	end
end
-- 限制不能从额外卡组特殊召唤「忍者」怪兽以外的怪兽
function c64749612.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsSetCard(0x2b) and c:IsLocation(LOCATION_EXTRA)
end
