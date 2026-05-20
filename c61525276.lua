--呪われし竜－カース・オブ・ドラゴン
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤成功的场合才能发动。从卡组把有「龙骑士 盖亚」的卡名记述的1张魔法·陷阱卡加入手卡。
-- ②：这张卡被送去墓地的场合，以自己场上1只「龙骑士 盖亚」为对象才能发动。持有那只怪兽的攻击力以下的攻击力的对方场上的全部表侧表示怪兽的效果直到回合结束时无效化。
function c61525276.initial_effect(c)
	-- 注册该卡记述了「龙骑士 盖亚」的卡片密码
	aux.AddCodeList(c,66889139)
	-- ①：这张卡召唤·特殊召唤成功的场合才能发动。从卡组把有「龙骑士 盖亚」的卡名记述的1张魔法·陷阱卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(61525276,0))
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,61525276)
	e1:SetTarget(c61525276.thtg)
	e1:SetOperation(c61525276.thop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：这张卡被送去墓地的场合，以自己场上1只「龙骑士 盖亚」为对象才能发动。持有那只怪兽的攻击力以下的攻击力的对方场上的全部表侧表示怪兽的效果直到回合结束时无效化。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(61525276,1))
	e3:SetCategory(CATEGORY_DISABLE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,61525277)
	e3:SetTarget(c61525276.distg)
	e3:SetOperation(c61525276.disop)
	c:RegisterEffect(e3)
end
-- 检索过滤条件：卡组中记述有「龙骑士 盖亚」卡名的魔法·陷阱卡
function c61525276.thfilter(c)
	-- 过滤出记述有「龙骑士 盖亚」卡名且能加入手卡的魔法·陷阱卡
	return aux.IsCodeListed(c,66889139) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- 效果①的发动准备与效果处理检查
function c61525276.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己卡组是否存在满足条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c61525276.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息为从卡组将1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果①的效果处理：从卡组将1张满足条件的卡加入手卡
function c61525276.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1张满足条件的卡
	local g=Duel.SelectMatchingCard(tp,c61525276.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡加入手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方确认加入手卡的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 效果②的对象过滤条件：自己场上表侧表示的「龙骑士 盖亚」且对方场上有可被其无效的怪兽
function c61525276.cfilter(c,tp)
	-- 过滤出自己场上表侧表示的「龙骑士 盖亚」且对方场上有攻击力在其以下的可无效化怪兽
	return c:IsFaceup() and c:IsCode(66889139) and Duel.IsExistingMatchingCard(c61525276.disfilter,tp,0,LOCATION_MZONE,1,nil,c:GetAttack())
end
-- 对方场上要无效的怪兽的过滤条件：攻击力在指定数值以下的可无效化怪兽
function c61525276.disfilter(c,atk)
	-- 过滤出攻击力在指定数值以下且未被无效的表侧表示效果怪兽
	return aux.NegateMonsterFilter(c) and c:IsAttackBelow(atk)
end
-- 效果②的发动准备与选择对象
function c61525276.distg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c61525276.cfilter(chkc,tp) end
	-- 检查自己场上是否存在符合条件的可作为对象的「龙骑士 盖亚」
	if chk==0 then return Duel.IsExistingTarget(c61525276.cfilter,tp,LOCATION_MZONE,0,1,nil,tp) end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择自己场上1只符合条件的「龙骑士 盖亚」作为效果对象
	Duel.SelectTarget(tp,c61525276.cfilter,tp,LOCATION_MZONE,0,1,1,nil,tp)
end
-- 效果②的效果处理：将对方场上攻击力在对象怪兽以下的全部表侧表示怪兽的效果无效化
function c61525276.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中被选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		local atk=tc:GetAttack()
		-- 获取对方场上所有攻击力在对象怪兽攻击力以下的可无效化怪兽
		local g=Duel.GetMatchingGroup(c61525276.disfilter,tp,0,LOCATION_MZONE,nil,atk)
		local tc=g:GetFirst()
		while tc do
			-- 无效化与目标怪兽相关的连锁
			Duel.NegateRelatedChain(tc,RESET_TURN_SET)
			-- 效果直到回合结束时无效化
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e1)
			-- 效果直到回合结束时无效化
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			e2:SetValue(RESET_TURN_SET)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e2)
			tc=g:GetNext()
		end
	end
end
