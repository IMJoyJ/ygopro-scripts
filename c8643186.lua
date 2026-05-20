--DDリクルート
-- 效果：
-- 「DD征募」在1回合只能发动1张。
-- ①：对方场上的怪兽数量比自己场上的怪兽多的场合，以最多有那个相差数量的自己墓地的「DD」怪兽或者「契约书」卡为对象才能发动。那些卡加入手卡。
function c8643186.initial_effect(c)
	-- 「DD征募」在1回合只能发动1张。①：对方场上的怪兽数量比自己场上的怪兽多的场合，以最多有那个相差数量的自己墓地的「DD」怪兽或者「契约书」卡为对象才能发动。那些卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,8643186+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c8643186.condition)
	e1:SetTarget(c8643186.target)
	e1:SetOperation(c8643186.operation)
	c:RegisterEffect(e1)
end
-- 发动条件：判定对方场上的怪兽数量是否比自己场上的怪兽多
function c8643186.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 返回对方场上的怪兽数量大于自己场上的怪兽数量这一条件
	return Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)
end
-- 过滤自己墓地的「DD」怪兽或者「契约书」卡，且能加入手卡
function c8643186.filter(c)
	return ((c:IsSetCard(0xaf) and c:IsType(TYPE_MONSTER)) or c:IsSetCard(0xae)) and c:IsAbleToHand()
end
-- 效果发动时的目标选择处理：检查合法对象，计算双方场上怪兽数量差，并选择对应数量的墓地目标
function c8643186.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c8643186.filter(chkc) end
	-- 在发动阶段检查自己墓地是否存在至少1张符合条件的卡作为对象
	if chk==0 then return Duel.IsExistingTarget(c8643186.filter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 计算对方场上怪兽数量与自己场上怪兽数量的相差值
	local ct=Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)-Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)
	-- 给发动玩家发送“请选择要加入手牌的卡”的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择最多有相差数量的自己墓地的目标卡片
	local g=Duel.SelectTarget(tp,c8643186.filter,tp,LOCATION_GRAVE,0,1,ct,nil)
	-- 设置效果处理信息，表示此效果的操作分类为加入手卡，操作对象为选中的卡片组
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,g:GetCount(),0,0)
end
-- 效果处理的执行：获取选中的对象，将仍存在于墓地且与效果相关的卡加入手卡
function c8643186.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选为效果对象的卡片组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local sg=g:Filter(Card.IsRelateToEffect,nil,e)
	if sg:GetCount()>0 then
		-- 将符合条件的对象卡片加入持有者的手卡
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
	end
end
