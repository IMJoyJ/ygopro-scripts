--オノマト選択
-- 效果：
-- 这个卡名的卡在1回合只能发动1张，这个卡名的②的效果1回合只能使用1次。
-- ①：作为这张卡的发动时的效果处理，可以从卡组把「拟声选择」以外的1张「拟声」卡加入手卡。
-- ②：以自己场上的「刷拉拉」、「我我我」、「隆隆隆」、「怒怒怒」怪兽之内任意1只为对象才能发动。自己场上的全部怪兽的等级直到回合结束时变成和作为对象的怪兽相同等级。
function c85119159.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：作为这张卡的发动时的效果处理，可以从卡组把「拟声选择」以外的1张「拟声」卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,85119159+EFFECT_COUNT_CODE_OATH)
	e1:SetOperation(c85119159.activate)
	c:RegisterEffect(e1)
	-- 这个卡名的②的效果1回合只能使用1次。②：以自己场上的「刷拉拉」、「我我我」、「隆隆隆」、「怒怒怒」怪兽之内任意1只为对象才能发动。自己场上的全部怪兽的等级直到回合结束时变成和作为对象的怪兽相同等级。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(85119159,0))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetCountLimit(1,85119160)
	e2:SetRange(LOCATION_SZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetTarget(c85119159.target)
	e2:SetOperation(c85119159.operation)
	c:RegisterEffect(e2)
end
-- 过滤卡组中「拟声选择」以外的「拟声」卡
function c85119159.filter(c)
	return c:IsAbleToHand() and c:IsSetCard(0x13a) and not c:IsCode(85119159)
end
-- ①号效果（卡片发动时的效果处理）的函数，用于检索「拟声」卡
function c85119159.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取卡组中所有满足过滤条件的卡片
	local g=Duel.GetMatchingGroup(c85119159.filter,tp,LOCATION_DECK,0,nil)
	-- 若卡组中存在可检索的卡，则询问玩家是否发动检索效果
	if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(85119159,1)) then  --"是否从卡组把1张「拟声」卡加入手卡？"
		-- 设置选择卡片时的提示信息为“请选择要加入手牌的卡”
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 将选中的卡片加入玩家手牌
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手牌的卡片
		Duel.ConfirmCards(1-tp,sg)
	end
end
-- 过滤自己场上表侧表示、有等级且属于「刷拉拉」、「我我我」、「隆隆隆」、「怒怒怒」系列的怪兽
function c85119159.filter1(c)
	return c:IsFaceup() and c:GetLevel()>0 and c:IsSetCard(0x8f,0x54,0x59,0x82)
end
-- 过滤自己场上表侧表示且有等级的怪兽
function c85119159.filter2(c)
	return c:IsFaceup() and c:GetLevel()>0
end
-- ②号效果的靶向判定与对象选择函数
function c85119159.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c85119159.filter1(chkc) end
	-- 检查自己场上是否存在可以作为对象的「刷拉拉」、「我我我」、「隆隆隆」、「怒怒怒」怪兽
	if chk==0 then return Duel.IsExistingTarget(c85119159.filter1,tp,LOCATION_MZONE,0,1,nil)
		-- 并且自己场上存在至少2只表侧表示且有等级的怪兽（确保有其他怪兽可以改变等级）
		and Duel.IsExistingMatchingCard(c85119159.filter2,tp,LOCATION_MZONE,0,2,nil) end
	-- 设置选择对象时的提示信息为“请选择效果的对象”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择自己场上的1只「刷拉拉」、「我我我」、「隆隆隆」、「怒怒怒」怪兽作为效果对象
	Duel.SelectTarget(tp,c85119159.filter1,tp,LOCATION_MZONE,0,1,1,nil)
end
-- ②号效果的执行函数，用于改变场上怪兽的等级
function c85119159.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 获取自己场上除对象怪兽以外的其他所有表侧表示且有等级的怪兽
		local g=Duel.GetMatchingGroup(c85119159.filter2,tp,LOCATION_MZONE,0,tc)
		local lc=g:GetFirst()
		local lv=tc:GetLevel()
		while lc do
			-- 自己场上的全部怪兽的等级直到回合结束时变成和作为对象的怪兽相同等级。
			local e2=Effect.CreateEffect(e:GetHandler())
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_CHANGE_LEVEL)
			e2:SetValue(lv)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			lc:RegisterEffect(e2)
			lc=g:GetNext()
		end
	end
end
