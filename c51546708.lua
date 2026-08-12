--DTナイトメア・ハンド
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：把手卡的这张卡给对方观看才能发动。进行1只「暗黑调整」怪兽的召唤。
-- ②：这张卡召唤的场合才能发动。从手卡把1只2星以下的怪兽特殊召唤。
-- ③：1回合1次，这张卡是已通常召唤的场合才能发动。自己场上的同是表侧表示的持有比这张卡低的等级的除调整以外的怪兽1只和这张卡解放，和那个等级差相同等级的1只同调怪兽当作同调召唤从额外卡组特殊召唤。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包括展示手牌进行召唤的效果、召唤成功的特殊召唤效果以及作为已通常召唤状态的拟同调召唤效果
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
	-- ②：这张卡召唤的场合才能发动。从手卡把1只2星以下的怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	-- ③：1回合1次，这张卡是已通常召唤的场合才能发动。自己场上的同是表侧表示的持有比这张卡低的等级的除调整以外的怪兽1只和这张卡解放，和那个等级差相同等级的1只同调怪兽当作同调召唤从额外卡组特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))  --"同调召唤"
	e3:SetCategory(CATEGORY_RELEASE+CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(s.spcon2)
	e3:SetTarget(s.sptg2)
	e3:SetOperation(s.spop2)
	c:RegisterEffect(e3)
end
-- 召唤效果的发动代价过滤：此卡在手牌中且处于非公开状态
function s.sumcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsPublic() end
end
-- 手牌或场上可以被召唤的「暗黑调整」怪兽的过滤条件
function s.sumfilter(c)
	return c:IsSetCard(0x1de) and c:IsSummonable(true,nil)
end
-- 召唤效果的发动目标检测与通常召唤操作信息注册
function s.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手牌或场上是否存在可以被召唤的「暗黑调整」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.sumfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil) end
	-- 设置召唤1只怪兽的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,1,0,0)
end
-- 召唤效果的处理：从手牌或场上选择1只「暗黑调整」怪兽进行通常召唤
function s.sumop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家发送提示，指示选择要召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)  --"请选择要召唤的卡"
	-- 让玩家从手牌或场上选择1只满足条件的「暗黑调整」怪兽
	local tc=Duel.SelectMatchingCard(tp,s.sumfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil):GetFirst()
	if tc then
		-- 将选择的怪兽无视每回合通常召唤次数限制进行通常召唤
		Duel.Summon(tp,tc,true,nil)
	end
end
-- 手牌特殊召唤的怪兽过滤条件：等级在2星以下且可以被特殊召唤
function s.spfilter(c,e,tp)
	return c:IsLevelBelow(2) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 特殊召唤效果的发动目标检测，检查场上空位和手牌中是否有符合条件的怪兽，并注册特殊召唤操作信息
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己的怪兽区是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手牌中是否存在满足过滤条件的2星以下怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置从手牌特殊召唤1只怪兽的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 特殊召唤效果的处理：从手牌选择1只2星以下的怪兽特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 如果怪兽区没有空余位置，则终止效果处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家发送提示，指示选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手牌中选择1张满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以正面表示特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 拟同调召唤效果的发动条件判断：此卡是已通常召唤的场合
function s.spcon2(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_NORMAL)
end
-- 用于解放的另一只怪兽的过滤条件：等级比此卡低、非调整、可解放且在额外卡组存在差值等级的同调怪兽
function s.rlfilter(c,e,tp,ec)
	return c:IsLevelAbove(1) and ec:GetLevel()>c:GetLevel() and c:IsReleasable(REASON_EFFECT)
		and not c:IsType(TYPE_TUNER) and c:IsFaceup()
		-- 检查额外卡组是否存在与两个被解放怪兽等级之差相同等级的同调怪兽且可进行特殊召唤
		and Duel.IsExistingMatchingCard(s.spfilter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,ec:GetLevel()-c:GetLevel(),Group.FromCards(c,ec))
end
-- 额外卡组特殊召唤的同调怪兽的过滤条件：等级等于指定的等级差、是同调怪兽且可以被同调召唤特殊召唤，并满足额外区域空位要求
function s.spfilter2(c,e,tp,lv,sg)
	return c:IsLevel(lv) and c:IsType(TYPE_SYNCHRO) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_SYNCHRO,tp,false,false)
		-- 检查若解放这2张怪兽（sg）后，额外卡组的同调怪兽是否有能出场的区域空位
		and Duel.GetLocationCountFromEx(tp,tp,sg,c)>0
end
-- 拟同调召唤效果的目标检测与解放、特殊召唤操作信息的注册
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查场上是否存在满足解放条件的另一只怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.rlfilter,tp,LOCATION_MZONE,0,1,c,e,tp,c)
		-- 检查玩家是否受到必须成为同调素材等相关卡片效果的限制
		and aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_SMATERIAL)
		and c:IsReleasable(REASON_EFFECT) end
	-- 设置解放场上2张怪兽的操作信息
	Duel.SetOperationInfo(0,CATEGORY_RELEASE,nil,2,tp,LOCATION_MZONE)
	-- 设置从额外卡组特殊召唤1只怪兽的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 拟同调召唤效果的执行处理：解放此卡与场上另一只满足条件的怪兽，从额外卡组将等级等于两卡等级差的1只同调怪兽当作同调召唤特殊召唤
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToChain() or not c:IsFaceup() or not c:IsReleasable(REASON_EFFECT) then return end
	-- 检查如果存在必须成为同调素材的限制且无法执行，则终止处理
	if not aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_SMATERIAL) then return end
	-- 向玩家发送提示，指示选择要解放的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	-- 让玩家从场上选择1只满足解放条件的怪兽
	local tc=Duel.SelectMatchingCard(tp,s.rlfilter,tp,LOCATION_MZONE,0,1,1,e:GetHandler(),e,tp,e:GetHandler()):GetFirst()
	if tc then
		local lv=c:GetLevel()-tc:GetLevel()
		-- 将此卡与选择的怪兽因效果解放，并判断是否成功解放
		if Duel.Release(Group.FromCards(c,tc),REASON_EFFECT)>0 then
			-- 向玩家发送提示，指示选择要特殊召唤的卡片
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			-- 让玩家从额外卡组选择1只等级等于两卡等级差且满足条件的同调怪兽
			local g=Duel.SelectMatchingCard(tp,s.spfilter2,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,lv,nil)
			local sc=g:GetFirst()
			if sc then
				sc:SetMaterial(nil)
				-- 将选择的同调怪兽以正面表示特殊召唤到场上，并判断是否召唤成功
				if Duel.SpecialSummon(sc,SUMMON_TYPE_SYNCHRO,tp,tp,false,false,POS_FACEUP)>0 then
					sc:CompleteProcedure()
				end
			end
		end
	end
end
