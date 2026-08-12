--DTカタストローグ
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：把手卡的这张卡给对方观看才能发动。进行1只「暗黑调整」怪兽的召唤。
-- ②：1回合1次，这张卡是已通常召唤的场合才能发动。自己场上的同是表侧表示的持有比这张卡低的等级的除调整以外的怪兽1只和这张卡解放，和那个等级差相同等级的1只同调怪兽当作同调召唤从额外卡组特殊召唤。那之后，可以把对方场上1张卡破坏。
local s,id,o=GetID()
-- 初始化卡片效果：注册手卡公开并进行「暗黑调整」通常召唤的起动效果，注册解放自身和另1只表侧表示非调整怪兽来特召同调怪兽并可选择破坏对方场上1张卡片的起动效果。
function s.initial_effect(c)
	-- ①：把手卡的这张卡给对方观看才能发动。进行1只「暗黑调整」怪兽的召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"进行召唤"
	e1:SetCategory(CATEGORY_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.sumcost)
	e1:SetTarget(s.sumtg)
	e1:SetOperation(s.sumop)
	c:RegisterEffect(e1)
	-- ②：1回合1次，这张卡是已通常召唤的场合才能发动。自己场上的同是表侧表示的持有比这张卡低的等级的除调整以外的怪兽1只和这张卡解放，和那个等级差相同等级的1只同调怪兽当作同调召唤从额外卡组特殊召唤。那之后，可以把对方场上1张卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"同调召唤"
	e2:SetCategory(CATEGORY_RELEASE+CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
-- 进行召唤效果的发动代价：将手牌中的这张卡给对方观看。
function s.sumcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsPublic() end
end
-- 过滤条件：属于「暗黑调整」字段且能够被通常召唤。
function s.sumfilter(c)
	return c:IsSetCard(0x1de) and c:IsSummonable(true,nil)
end
-- 通常召唤效果的发动准备与检查：在效果发动时，检查自己手牌或场上是否存在符合通常召唤条件的「暗黑调整」怪兽。
function s.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动时，检查自己手牌或场上是否存在至少1只能够通常召唤的「暗黑调整」怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.sumfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil) end
	-- 设置连锁操作信息：包含通常召唤的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,1,0,0)
end
-- 通常召唤效果的处理：从自己手牌或场上选择1只满足条件的「暗黑调整」怪兽进行通常召唤。
function s.sumop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要召唤的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)  --"请选择要召唤的卡"
	-- 从自己手牌或场上选择1只可以进行通常召唤的「暗黑调整」怪兽。
	local tc=Duel.SelectMatchingCard(tp,s.sumfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil):GetFirst()
	if tc then
		-- 无视每回合的通常召唤次数限制，对所选怪兽进行通常召唤。
		Duel.Summon(tp,tc,true,nil)
	end
end
-- 判断同调特召效果的发动条件是否满足：这张卡是以通常召唤方式出场的。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_NORMAL)
end
-- 过滤条件：比这张卡等级低的表侧表示非调整怪兽，且可以被效果解放，同时其与这张卡的等级差存在可从额外卡组同调特殊召唤的同调怪兽。
function s.rlfilter(c,e,tp,ec)
	return c:IsLevelAbove(1) and ec:GetLevel()>c:GetLevel() and c:IsReleasable(REASON_EFFECT)
		and not c:IsType(TYPE_TUNER) and c:IsFaceup()
		-- 检查额外卡组中是否存在可以以同调召唤方式特殊召唤的、等级等于两张卡片等级差的同调怪兽。
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,ec:GetLevel()-c:GetLevel(),Group.FromCards(c,ec))
end
-- 过滤条件：属于同调怪兽且等级等于指定等级差，可以进行同调特殊召唤。
function s.spfilter(c,e,tp,lv,sg)
	return c:IsLevel(lv) and c:IsType(TYPE_SYNCHRO) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_SYNCHRO,tp,false,false)
		-- 检查在解放指定的两只怪兽后，自己场上是否有空余的格子用于从额外卡组特殊召唤该同调怪兽。
		and Duel.GetLocationCountFromEx(tp,tp,sg,c)>0
end
-- 同调特召效果的发动准备与检查：检查自己场上是否有符合解放条件的怪兽，自己是否受到必须使用特定素材的限制，以及自身是否可以被效果解放。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 在效果发动时，检查自己场上是否存在满足条件的、用于与这张卡一起解放的非调整怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.rlfilter,tp,LOCATION_MZONE,0,1,c,e,tp,c)
		-- 检查自己是否受到必须将场上特定怪兽作为同调素材的效果限制。
		and aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_SMATERIAL)
		and c:IsReleasable(REASON_EFFECT) end
	-- 设置连锁操作信息：包含解放自己场上2只怪兽的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_RELEASE,nil,2,tp,LOCATION_MZONE)
	-- 设置连锁操作信息：包含从额外卡组特殊召唤1只怪兽的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 同调特召效果的处理：解放自身和场上1只等级较低的表侧表示非调整怪兽，将等级差相同的一只同调怪兽当作同调召唤从额外卡组特殊召唤。之后，可以选择破坏对方场上1张卡。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToChain() or not c:IsFaceup() or not c:IsReleasable(REASON_EFFECT) then return end
	-- 在效果处理时，检查是否满足必须使用特定怪兽作为同调素材的规则约束。
	if not aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_SMATERIAL) then return end
	-- 提示玩家选择要解放的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	-- 从自己场上选择1只满足等级低于本卡且为非调整等过滤条件的表侧表示怪兽。
	local tc=Duel.SelectMatchingCard(tp,s.rlfilter,tp,LOCATION_MZONE,0,1,1,c,e,tp,c):GetFirst()
	if tc then
		local lv=c:GetLevel()-tc:GetLevel()
		-- 解放这张卡和所选的另1只怪兽，并判断是否解放成功。
		if Duel.Release(Group.FromCards(c,tc),REASON_EFFECT)>0 then
			-- 提示玩家选择要特殊召唤的同调怪兽。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			-- 从额外卡组选择1只满足等级为等级差等过滤条件的同调怪兽。
			local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,lv,nil)
			local sc=g:GetFirst()
			if sc then
				sc:SetMaterial(nil)
				-- 将选定的同调怪兽以表侧表示当作同调召唤特殊召唤到自己场上，并判断是否召唤成功。
				if Duel.SpecialSummon(sc,SUMMON_TYPE_SYNCHRO,tp,tp,false,false,POS_FACEUP)~=0 then
					sc:CompleteProcedure()
					-- 特殊召唤成功后，若对方场上存在卡片，询问玩家是否进行破坏。
					if Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否把卡破坏？"
						-- 中断效果处理，使后续的破坏操作与先前的特殊召唤操作不视为同时进行。
						Duel.BreakEffect()
						-- 提示玩家选择要破坏的卡片。
						Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
						-- 从对方场上选择1张任意类型的卡片进行破坏。
						local sg=Duel.SelectMatchingCard(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,1,nil)
						-- 手动为所选的被破坏卡片显示选中动画。
						Duel.HintSelection(sg)
						-- 通过效果破坏所选择的卡片。
						Duel.Destroy(sg,REASON_EFFECT)
					end
				end
			end
		end
	end
end
