--マジェスペクター・ラクーン
-- 效果：
-- ←5 【灵摆】 5→
-- 【怪兽效果】
-- 这个卡名的①的怪兽效果1回合只能使用1次。
-- ①：这张卡召唤·特殊召唤时才能发动。从卡组把1只「威风妖怪」怪兽加入手卡。
-- ②：只要这张卡在怪兽区域存在，这张卡不会被对方的效果破坏，对方不能把这张卡作为效果的对象。
function c31991800.initial_effect(c)
	-- 给这张卡注册灵摆怪兽属性（灵摆召唤、灵摆刻度、灵摆区发动等）。
	aux.EnablePendulumAttribute(c)
	-- 这个卡名的①的怪兽效果1回合只能使用1次。①：这张卡召唤·特殊召唤时才能发动。从卡组把1只「威风妖怪」怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCountLimit(1,31991800)
	e2:SetTarget(c31991800.thtg)
	e2:SetOperation(c31991800.thop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	-- ②：只要这张卡在怪兽区域存在，对方不能把这张卡作为效果的对象。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	-- 设置“不能成为效果对象”的判定条件：只有本方（控制者）的效果才能以这张卡为对象，对方的效果不能以这张卡为对象，对应②的后半句。
	e4:SetValue(aux.tgoval)
	c:RegisterEffect(e4)
	-- ②：只要这张卡在怪兽区域存在，这张卡不会被对方的效果破坏。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e5:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e5:SetRange(LOCATION_MZONE)
	-- 设置“不会被效果破坏”的判定条件：对方发动的效果不能破坏这张卡，对应②的前半句。
	e5:SetValue(aux.indoval)
	c:RegisterEffect(e5)
end
-- 定义检索过滤函数：只接受卡组中满足“卡名含‘威风妖怪’字段、是怪兽卡、且能加入手卡”的卡。
function c31991800.thfilter(c)
	return c:IsSetCard(0xd0) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 发动条件与操作信息登记：先判断是否能从卡组找到检索目标；若可以，则声明本次效果将把卡组的1张卡加入手卡。
function c31991800.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动合法性检查：检索卡组中是否存在至少1张满足条件的「威风妖怪」怪兽，存在才允许发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c31991800.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 登记操作信息：告知系统本效果会将卡组1张卡加入手卡（目标在处理时再确定，不取对象）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理流程：由当前玩家从卡组选择1只符合条件的「威风妖怪」怪兽加入手卡，并向对方确认加入手卡的卡。
function c31991800.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 显示“请选择要加入手牌的卡”的选择提示，供玩家选择卡组卡片时使用。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 执行选择：从自己卡组选出1张满足过滤条件的「威风妖怪」怪兽（min=max=1，只能选1张）。
	local g=Duel.SelectMatchingCard(tp,c31991800.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 把所选卡片以效果原因加入其持有者的手卡（nil表示返回持有者手卡）。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对方玩家确认加入手卡的卡片，确保公开检索信息。
		Duel.ConfirmCards(1-tp,g)
	end
end
