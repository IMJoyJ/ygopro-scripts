--氷水底イニオン・クレイドル
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：作为这张卡的发动时的效果处理，可以把自己的墓地·除外状态的1只「冰水」怪兽加入手卡。
-- ②：1回合1次，怪兽召唤·特殊召唤的场合，以自己场上1只水属性怪兽为对象才能发动。作为对象的怪兽以及对方场上的全部表侧表示怪兽的攻击力直到回合结束时下降作为对象的怪兽的原本攻击力数值。
function c7142724.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：作为这张卡的发动时的效果处理，可以把自己的墓地·除外状态的1只「冰水」怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_GRAVE_ACTION)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,7142724+EFFECT_COUNT_CODE_OATH)
	e1:SetOperation(c7142724.activate)
	c:RegisterEffect(e1)
	-- ②：1回合1次，怪兽召唤·特殊召唤的场合，以自己场上1只水属性怪兽为对象才能发动。作为对象的怪兽以及对方场上的全部表侧表示怪兽的攻击力直到回合结束时下降作为对象的怪兽的原本攻击力数值。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(7142724,1))
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1,EFFECT_COUNT_CODE_SINGLE)
	e2:SetTarget(c7142724.adtg)
	e2:SetOperation(c7142724.adop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
end
-- 过滤条件：自己墓地或除外状态（表侧表示）的「冰水」怪兽
function c7142724.thfilter(c)
	return c:IsSetCard(0x16c) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
		and (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup())
end
-- 卡片发动时的效果处理：可以从墓地或除外状态将1只「冰水」怪兽加入手卡
function c7142724.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己墓地及除外状态下满足条件的「冰水」怪兽（受王家之谷影响）
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(c7142724.thfilter),tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil)
	-- 若存在可加入手卡的怪兽，则由玩家选择是否发动该效果
	if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(7142724,0)) then  --"是否选「冰水」怪兽加入手卡？"
		-- 提示玩家选择要加入手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 将选中的卡加入手卡
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手卡的卡
		Duel.ConfirmCards(1-tp,sg)
	end
end
-- 过滤条件：自己场上表侧表示且原本攻击力大于0的水属性怪兽
function c7142724.adfilter(c)
	return c:IsAttribute(ATTRIBUTE_WATER) and c:IsFaceup() and c:GetBaseAttack()>0
end
-- 效果②的靶向处理：选择自己场上1只表侧表示的水属性怪兽作为对象
function c7142724.adtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c7142724.adfilter(chkc) end
	-- 在发动阶段，检查自己场上是否存在符合条件的可作为对象的水属性怪兽
	if chk==0 then return Duel.IsExistingTarget(c7142724.adfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择并锁定自己场上1只符合条件的水属性怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c7142724.adfilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置操作信息：此效果包含改变攻击力的操作，对象为选中的怪兽
	Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,g,1,0,0)
end
-- 效果②的执行处理：使作为对象的怪兽以及对方场上全部表侧表示怪兽的攻击力下降该对象怪兽的原本攻击力数值
function c7142724.adop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取作为效果对象的那只怪兽
	local tc=Duel.GetFirstTarget()
	if not (tc:IsRelateToEffect(e) and tc:IsFaceup()) then return end
	-- 获取对方场上所有表侧表示的怪兽
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	g:AddCard(tc)
	local tc1=g:GetFirst()
	while tc1 do
		-- 攻击力直到回合结束时下降作为对象的怪兽的原本攻击力数值
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(-tc:GetBaseAttack())
		tc1:RegisterEffect(e1)
		tc1=g:GetNext()
	end
end
