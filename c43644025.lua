--コクーン・リボーン
-- 效果：
-- 可以把自己场上表侧表示存在的1只名字带有「茧状体」的怪兽作为祭品，那张卡记述的1只名字带有「新空间侠」的怪兽从墓地特殊召唤。
function c43644025.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 可以把自己场上表侧表示存在的1只名字带有「茧状体」的怪兽作为祭品，那张卡记述的1只名字带有「新空间侠」的怪兽从墓地特殊召唤。
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
-- 过滤可作为祭品的「茧状体」怪兽：该卡表侧表示且具有「茧状体」字段，同时墓地存在可由该卡记述的「新空间侠」怪兽作为特殊召唤对象的场合，返回真。
function c43644025.filter1(c,e,tp)
	-- 判断c是否满足「茧状体」祭品条件，并确认墓地中是否存在至少1只对应的「新空间侠」怪兽可成为特殊召唤对象。
	return c:IsFaceup() and c:IsSetCard(0x1e) and Duel.IsExistingTarget(c43644025.filter2,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil,c,e,tp)
end
-- 过滤墓地中可作为特殊召唤对象的「新空间侠」怪兽：要求该怪兽具有「新空间侠」字段、被解放的「茧状体」怪兽的效果文本中记载了该怪兽的卡名，且该怪兽能够被特殊召唤。
function c43644025.filter2(c,mc,e,tp)
	-- 确认c具有「新空间侠」字段，且mc（祭品怪兽）的效果文本记载了c的卡名，并且c满足特殊召唤条件。
	return c:IsSetCard(0x1f) and aux.IsCodeListed(mc,c:GetCode()) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
-- 费用函数：只设置一个标记（e:SetLabel(1)）并返回真，实际解放将在target中选择祭品时完成，以此在发动时绕过代价支付检查。
function c43644025.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	return true
end
-- 目标处理：确认已执行过cost标记后，检查主要怪兽区/额外怪兽区有可用空格且场上存在可解放的「茧状体」怪兽；然后选择1只「茧状体」怪兽解放，并从墓地选择1只对应的「新空间侠」作为特殊召唤对象，同时设定操作信息。
function c43644025.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then
		local res=e:GetLabel()==1
		e:SetLabel(0)
		-- 检查我方场上的主要怪兽区与额外怪兽区合计是否有可用空格（条件写成>-1，即至少存在可用的怪兽区域）。
		return res and Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
			-- 并检查场上是否存在至少1只满足filter1条件的「茧状体」怪兽可以作为解放的祭品。
			and Duel.CheckReleaseGroup(tp,c43644025.filter1,1,nil,e,tp) end
	e:SetLabel(0)
	-- 选择1只满足filter1条件的「茧状体」怪兽作为解放代价。
	local rg=Duel.SelectReleaseGroup(tp,c43644025.filter1,1,1,nil,e,tp)
	-- 将选择的「茧状体」怪兽解放，该解放作为效果的发动代价（REASON_COST）。
	Duel.Release(rg,REASON_COST)
	-- 显示“请选择要特殊召唤的卡”的提示信息，供玩家选择墓地中的「新空间侠」怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从墓地选择1只满足filter2条件的「新空间侠」怪兽，并将其设为效果对象（Duel.SelectTarget会建立效果与对象的关联）。
	local g=Duel.SelectTarget(tp,c43644025.filter2,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil,rg:GetFirst(),e,tp)
	-- 设定操作信息为“特殊召唤”，处理时将会把对象怪兽特殊召唤，供其他连锁检测使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理：取得之前选择的对象，若对象仍与效果关联，则将其特殊召唤。
function c43644025.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果发动时选择的对象（墓地中要特殊召唤的「新空间侠」怪兽）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽以表侧表示特殊召唤到自己的场上。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
