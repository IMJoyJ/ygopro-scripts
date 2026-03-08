--コクーン・リボーン
-- 效果：
-- 可以把自己场上表侧表示存在的1只名字带有「茧状体」的怪兽作为祭品，那张卡记述的1只名字带有「新空间侠」的怪兽从墓地特殊召唤。
function c43644025.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 效果原文：可以把自己场上表侧表示存在的1只名字带有「茧状体」的怪兽作为祭品，那张卡记述的1只名字带有「新空间侠」的怪兽从墓地特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(43644025,0))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCost(c43644025.cost)
	e2:SetTarget(c43644025.target)
	e2:SetOperation(c43644025.activate)
	c:RegisterEffect(e2)
end
-- 检索满足条件的场上表侧表示存在的「茧状体」怪兽，用于作为祭品
function c43644025.filter1(c,e,tp)
	-- 满足条件的场上表侧表示存在的「茧状体」怪兽，用于作为祭品
	return c:IsFaceup() and c:IsSetCard(0x1e) and Duel.IsExistingTarget(c43644025.filter2,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil,c,e,tp)
end
-- 检索满足条件的墓地「新空间侠」怪兽，用于特殊召唤
function c43644025.filter2(c,mc,e,tp)
	-- 满足条件的墓地「新空间侠」怪兽，用于特殊召唤
	return c:IsSetCard(0x1f) and aux.IsCodeListed(mc,c:GetCode()) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
-- 设置效果标记，表示可以发动此效果
function c43644025.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	return true
end
-- 判断是否满足发动条件，包括是否有足够的召唤位置和可解放的「茧状体」怪兽
function c43644025.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then
		local res=e:GetLabel()==1
		e:SetLabel(0)
		-- 判断场上是否有足够的召唤位置
		return res and Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
			-- 判断是否满足可解放的「茧状体」怪兽条件
			and Duel.CheckReleaseGroup(tp,c43644025.filter1,1,nil,e,tp) end
	e:SetLabel(0)
	-- 选择1只满足条件的「茧状体」怪兽作为祭品
	local rg=Duel.SelectReleaseGroup(tp,c43644025.filter1,1,1,nil,e,tp)
	-- 将选择的「茧状体」怪兽从场上解放作为发动代价
	Duel.Release(rg,REASON_COST)
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择1只满足条件的墓地「新空间侠」怪兽作为特殊召唤目标
	local g=Duel.SelectTarget(tp,c43644025.filter2,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil,rg:GetFirst(),e,tp)
	-- 设置操作信息，表示将要特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 执行效果的处理，将目标怪兽特殊召唤
function c43644025.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽以正面表示形式特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
