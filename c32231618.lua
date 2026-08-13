--占術姫コインノーマ
-- 效果：
-- ①：这张卡反转的场合才能发动。从手卡·卡组把1只3星以上的反转怪兽里侧守备表示特殊召唤。这个效果的发动后，直到回合结束时自己不能把「占术姬」怪兽以外的怪兽的效果发动。
function c32231618.initial_effect(c)
	-- ①：这张卡反转的场合才能发动。从手卡·卡组把1只3星以上的反转怪兽里侧守备表示特殊召唤。这个效果的发动后，直到回合结束时自己不能把「占术姬」怪兽以外的怪兽的效果发动。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_MSET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetTarget(c32231618.sptg)
	e1:SetOperation(c32231618.spop)
	c:RegisterEffect(e1)
end
-- 过滤函数：判定候选怪兽必须是反转怪兽、等级在3星以上，并且能够被特殊召唤为里侧守备表示。
function c32231618.spfilter(c,e,tp)
	return c:IsType(TYPE_FLIP) and c:IsLevelAbove(3) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE)
end
-- 效果发动条件的合法性检测：检查自己场上是否有可用的主要怪兽区域空格，并且手牌·卡组中是否存在满足过滤条件的反转怪兽。
function c32231618.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动时检查自己的主要怪兽区是否有空格，确保能进行特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 在发动时检查手牌·卡组中是否存在至少1张满足 spfilter 过滤条件的反转怪兽。
		and Duel.IsExistingMatchingCard(c32231618.spfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置本次效果的操作信息：将进行1次从手牌·卡组的特殊召唤，用于后续连锁判定和效果检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_HAND)
end
-- 效果处理：若主要怪兽区有空位，从手牌·卡组选出1只符合条件的反转怪兽以里侧守备表示特殊召唤并给对方确认；之后给自己附加直到回合结束不能发动「占术姬」以外的怪兽效果的制约。
function c32231618.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次确认自己的主要怪兽区仍有空格。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 向己方显示提示，要求选择要特殊召唤的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 己方从手牌·卡组中选出1张满足 spfilter 条件的反转怪兽。
		local g=Duel.SelectMatchingCard(tp,c32231618.spfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 将选中的怪兽以里侧守备表示特殊召唤到自己场上。
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)
			-- 向对方玩家展示特殊召唤的里侧怪兽，使其知晓召唤的是哪张卡。
			Duel.ConfirmCards(1-tp,g)
		end
	end
	-- 这个效果的发动后，直到回合结束时自己不能把「占术姬」怪兽以外的怪兽的效果发动。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetValue(c32231618.actlimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将前述自肃效果（不能发动非「占术姬」怪兽效果）注册为场上持续生效的效果，影响己方。
	Duel.RegisterEffect(e1,tp)
end
-- 自肃判定函数：若一次效果发动是怪兽效果的发动，且发动效果的怪兽不持有「占术姬」字段，则禁止该发动。
function c32231618.actlimit(e,re,rp)
	local rc=re:GetHandler()
	return re:IsActiveType(TYPE_MONSTER) and not rc:IsSetCard(0xcc)
end
