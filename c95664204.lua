--ゼアル・カタパルト
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：从手卡把1只「异热同心武器」怪兽或者「异热同心从者」怪兽特殊召唤。自己场上有「希望皇 霍普」怪兽存在的场合，可以再把自己场上的全部怪兽的等级变成4星或者5星。
-- ②：把1只「异热同心武器」怪兽或者「异热同心从者」怪兽和这张卡从自己墓地除外，以对方场上1张卡为对象才能发动。那张卡破坏。这个效果在这张卡送去墓地的回合不能发动。
function c95664204.initial_effect(c)
	-- ①：从手卡把1只「异热同心武器」怪兽或者「异热同心从者」怪兽特殊召唤。自己场上有「希望皇 霍普」怪兽存在的场合，可以再把自己场上的全部怪兽的等级变成4星或者5星。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(95664204,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,95664204)
	e1:SetTarget(c95664204.target)
	e1:SetOperation(c95664204.activate)
	c:RegisterEffect(e1)
	-- ②：把1只「异热同心武器」怪兽或者「异热同心从者」怪兽和这张卡从自己墓地除外，以对方场上1张卡为对象才能发动。那张卡破坏。这个效果在这张卡送去墓地的回合不能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(95664204,1))  --"卡片破坏"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,95664205)
	-- 设置该效果在这张卡送去墓地的回合不能发动
	e2:SetCondition(aux.exccon)
	e2:SetCost(c95664204.descost)
	e2:SetTarget(c95664204.destg)
	e2:SetOperation(c95664204.desop)
	c:RegisterEffect(e2)
end
-- 过滤手卡中可以特殊召唤的「异热同心武器」或「异热同心从者」怪兽
function c95664204.filter(c,e,tp)
	return c:IsSetCard(0x107e,0x207e) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果①的发动准备与可行性检查
function c95664204.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡中是否存在可特殊召唤的「异热同心武器」或「异热同心从者」怪兽
		and Duel.IsExistingMatchingCard(c95664204.filter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置连锁处理中的操作信息为从手卡特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 过滤自己场上表侧表示的「希望皇 霍普」怪兽
function c95664204.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x107f)
end
-- 过滤自己场上表侧表示、有等级且等级不为4或不为5的怪兽
function c95664204.lvfilter(c)
	return c:IsFaceup() and c:IsLevelAbove(0) and (not c:IsLevel(4) or not c:IsLevel(5))
end
-- 效果①的处理函数（特殊召唤并可选改变等级）
function c95664204.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 若自己场上没有可用的怪兽区域则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家选择手卡中1只满足条件的怪兽
	local sg=Duel.SelectMatchingCard(tp,c95664204.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	-- 若成功将选择的怪兽表侧表示特殊召唤
	if sg:GetCount()>0 and Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)>0
		-- 检查自己场上是否存在「希望皇 霍普」怪兽
		and Duel.IsExistingMatchingCard(c95664204.cfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 检查自己场上是否存在可以改变等级的怪兽
		and Duel.IsExistingMatchingCard(c95664204.lvfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 询问玩家是否选择改变场上全部怪兽的等级
		and Duel.SelectYesNo(tp,aux.Stringid(95664204,2)) then  --"是否改变等级？"
		-- 中断当前效果处理，使后续的等级改变处理不与特殊召唤同时处理
		Duel.BreakEffect()
		-- 获取自己场上所有可以改变等级的怪兽
		local g=Duel.GetMatchingGroup(c95664204.lvfilter,tp,LOCATION_MZONE,0,nil)
		local lv=0
		if g:FilterCount(Card.IsLevel,nil,5)==#g then lv=4 end
		if g:FilterCount(Card.IsLevel,nil,4)==#g then lv=5 end
		-- 若场上怪兽等级不统一，则由玩家宣言等级4或5
		if lv==0 then lv=Duel.AnnounceNumber(tp,4,5) end
		local lc=g:GetFirst()
		while lc do
			-- 可以再把自己场上的全部怪兽的等级变成4星或者5星。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CHANGE_LEVEL)
			e1:SetValue(lv)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			lc:RegisterEffect(e1)
			lc=g:GetNext()
		end
	end
end
-- 过滤墓地中可以作为发动成本除外的「异热同心武器」或「异热同心从者」怪兽
function c95664204.costfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x107e,0x207e) and c:IsAbleToRemoveAsCost()
end
-- 效果②的发动成本处理函数（除外墓地的此卡和1只特定怪兽）
function c95664204.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToRemoveAsCost()
		-- 检查墓地中是否存在除此卡以外可作为发动成本除外的特定怪兽
		and Duel.IsExistingMatchingCard(c95664204.costfilter,tp,LOCATION_GRAVE,0,1,c) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 玩家选择墓地中1只满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c95664204.costfilter,tp,LOCATION_GRAVE,0,1,1,c)
	g:AddCard(c)
	-- 将选择的怪兽和墓地的此卡除外
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 效果②的发动准备与可行性检查（选择对方场上的1张卡为对象）
function c95664204.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) end
	-- 检查对方场上是否存在可以作为对象的卡
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 玩家选择对方场上1张卡作为效果对象
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置连锁处理中的操作信息为破坏选中的卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果②的处理函数（破坏作为对象的卡）
function c95664204.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 破坏作为对象的卡
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
