--E・HERO ブレイズマン
function c63060238.initial_effect(c)
	-- ①：这张卡召唤・特殊召唤成功的场合才能发动。从卡组把1张「融合」加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(63060238,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,63060238)
	e1:SetTarget(c63060238.thtg)
	e1:SetOperation(c63060238.thop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：自己主要阶段才能发动。从卡组把「E・HERO ブレイズマン」以外的1只「E・HERO」怪兽送去墓地。这张卡直到回合结束时，属性・攻击力・守备力变成和这个效果送去墓地的怪兽相同。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(63060238,1))
	e3:SetCategory(CATEGORY_TOGRAVE)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,63060238)
	e3:SetTarget(c63060238.tgtg)
	e3:SetOperation(c63060238.tgop)
	c:RegisterEffect(e3)
end
-- 过滤卡组中卡名为「融合」且能加入手牌的卡片
function c63060238.filter(c)
	return c:IsCode(24094653) and c:IsAbleToHand()
end
-- 检索效果的发动准备与效果分类注册
function c63060238.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断卡组中是否存在可以加入手牌的「融合」
	if chk==0 then return Duel.IsExistingMatchingCard(c63060238.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁处理中的操作信息为：从卡组将1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 检索效果的执行：从卡组选择1张「融合」加入手牌并给对方确认
function c63060238.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1张满足过滤条件的卡片
	local g=Duel.SelectMatchingCard(tp,c63060238.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡片因效果加入玩家手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手牌的卡片给对方玩家确认
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 过滤卡组中「E・HERO ブレイズマン」以外的「E・HERO」怪兽且能送去墓地的卡片
function c63060238.tgfilter(c)
	return c:IsSetCard(0x3008) and c:IsType(TYPE_MONSTER) and not c:IsCode(63060238) and c:IsAbleToGrave()
end
-- 送墓效果的发动准备与效果分类注册
function c63060238.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断卡组中是否存在可以送去墓地的「E・HERO」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c63060238.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁处理中的操作信息为：从卡组将1张卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 送墓及复制数值效果的执行：将怪兽送墓，并复制其属性、攻击力和守备力，同时适用特殊召唤限制
function c63060238.tgop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 提示玩家选择要送去墓地的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从卡组选择1张满足过滤条件的卡片
	local g=Duel.SelectMatchingCard(tp,c63060238.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	local tc=g:GetFirst()
	-- 若成功将目标怪兽送去墓地，且此卡仍在场上，则开始处理属性与攻防数值的变更
	if tc and Duel.SendtoGrave(tc,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_GRAVE)
		and c:IsRelateToEffect(e) then
		-- 属性・攻击力・守备力变成和这个效果送去墓地的怪兽相同。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_ATTRIBUTE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(tc:GetAttribute())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_SET_ATTACK_FINAL)
		e2:SetValue(tc:GetAttack())
		c:RegisterEffect(e2)
		local e3=e1:Clone()
		e3:SetCode(EFFECT_SET_DEFENSE_FINAL)
		e3:SetValue(tc:GetDefense())
		c:RegisterEffect(e3)
	end
	-- 这个效果的发动后，直到回合结束时自己不是融合怪兽不能特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetTargetRange(1,0)
	e4:SetTarget(c63060238.splimit)
	e4:SetReset(RESET_PHASE+PHASE_END)
	-- 在玩家身上注册「不能特殊召唤融合怪兽以外的怪兽」的限制效果
	Duel.RegisterEffect(e4,tp)
	-- 这个效果的发动后，直到回合结束时自己不是融合怪兽不能特殊召唤。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetCode(63060238)
	e5:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e5:SetTargetRange(1,0)
	e5:SetReset(RESET_PHASE+PHASE_END)
	-- 在玩家身上注册此卡效果已发动的标记效果
	Duel.RegisterEffect(e5,tp)
end
-- 限制特殊召唤的怪兽必须是融合怪兽
function c63060238.splimit(e,c,tp,sumtp,sumpos)
	return c:GetOriginalType()&TYPE_FUSION~=TYPE_FUSION
end
