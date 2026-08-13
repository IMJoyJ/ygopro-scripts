--エルシャドール・ネフィリム
-- 效果：
-- 「影依」怪兽＋光属性怪兽
-- 这张卡用融合召唤才能从额外卡组特殊召唤。
-- ①：这张卡特殊召唤的场合才能发动。从卡组把1张「影依」卡送去墓地。
-- ②：这张卡和特殊召唤的怪兽进行战斗的伤害步骤开始时发动。那只怪兽破坏。
-- ③：这张卡被送去墓地的场合，以自己墓地1张「影依」魔法·陷阱卡为对象才能发动。那张卡加入手卡。
function c20366274.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡注册影依融合召唤手续，指定融合素材为「影依」怪兽＋光属性怪兽。
	aux.AddFusionProcShaddoll(c,ATTRIBUTE_LIGHT)
	-- 这张卡用融合召唤才能从额外卡组特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetCode(EFFECT_SPSUMMON_CONDITION)
	e2:SetRange(LOCATION_EXTRA)
	e2:SetValue(c20366274.splimit)
	c:RegisterEffect(e2)
	-- ①：这张卡特殊召唤的场合才能发动。从卡组把1张「影依」卡送去墓地。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(20366274,0))  --"送墓"
	e3:SetCategory(CATEGORY_TOGRAVE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e3:SetTarget(c20366274.tgtg)
	e3:SetOperation(c20366274.tgop)
	c:RegisterEffect(e3)
	-- ②：这张卡和特殊召唤的怪兽进行战斗的伤害步骤开始时发动。那只怪兽破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(20366274,1))  --"破坏"
	e4:SetCategory(CATEGORY_DESTROY)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e4:SetCode(EVENT_BATTLE_START)
	e4:SetCondition(c20366274.descon)
	e4:SetTarget(c20366274.destg)
	e4:SetOperation(c20366274.desop)
	c:RegisterEffect(e4)
	-- ③：这张卡被送去墓地的场合，以自己墓地1张「影依」魔法·陷阱卡为对象才能发动。那张卡加入手卡。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(20366274,2))  --"加入手卡"
	e5:SetCategory(CATEGORY_TOHAND)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e5:SetCode(EVENT_TO_GRAVE)
	e5:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e5:SetTarget(c20366274.thtg)
	e5:SetOperation(c20366274.thop)
	c:RegisterEffect(e5)
end
-- 判定特殊召唤的类型是否为融合召唤，只有融合召唤才满足这张卡的特殊召唤条件。
function c20366274.splimit(e,se,sp,st)
	return bit.band(st,SUMMON_TYPE_FUSION)==SUMMON_TYPE_FUSION
end
-- 筛选存在于卡组中的「影依」卡且可以被送去墓地的卡，作为效果处理时可选的送墓对象。
function c20366274.tgfilter(c)
	return c:IsSetCard(0x9d) and c:IsAbleToGrave()
end
-- 效果发动前的合法性检查：确认卡组中存在符合条件的「影依」卡，并设置本次连锁的送墓操作信息。
function c20366274.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时判断卡组中是否存在至少1张符合条件的「影依」卡，若不存在则效果不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c20366274.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置本次效果的操作信息，声明效果处理时将从卡组把1张卡送去墓地。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 效果处理时，从卡组选择1张符合条件的「影依」卡送去墓地。
function c20366274.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 显示“请选择要送去墓地的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从自己的卡组中选出1张符合过滤条件的「影依」卡。
	local g=Duel.SelectMatchingCard(tp,c20366274.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选出的「影依」卡以效果原因送入墓地。
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
-- ②效果发动条件：这张卡与特殊召唤的怪兽进行战斗的伤害步骤开始时，且战斗对象为特殊召唤怪兽。
function c20366274.descon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	return bc and bc:IsSummonType(SUMMON_TYPE_SPECIAL)
end
-- ②效果发动时无需取对象，设置操作信息：将本次战斗对象破坏。
function c20366274.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息，声明将破坏那只战斗对象怪兽，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler():GetBattleTarget(),1,0,0)
end
-- 效果处理：若战斗对象仍存活且与本次战斗相关，则将其破坏。
function c20366274.desop(e,tp,eg,ep,ev,re,r,rp)
	local bc=e:GetHandler():GetBattleTarget()
	if bc:IsRelateToBattle() then
		-- 将那只特殊召唤的怪兽以效果原因破坏。
		Duel.Destroy(bc,REASON_EFFECT)
	end
end
-- 筛选自己墓地里「影依」魔法·陷阱卡且能够加入手卡的卡，作为③效果的对象候选。
function c20366274.thfilter(c)
	return c:IsSetCard(0x9d) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- ③效果的目标选择：从自己墓地选择1张符合条件的「影依」魔法·陷阱卡作为对象，并设置回手牌操作信息。
function c20366274.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c20366274.thfilter(chkc) end
	-- 发动时检查自己墓地中是否存在1张可成为效果对象的「影依」魔法·陷阱卡，且为取对象效果。
	if chk==0 then return Duel.IsExistingTarget(c20366274.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 显示“请选择要加入手牌的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从自己墓地选择1张符合条件的「影依」魔法·陷阱卡，并将它设为效果的对象。
	local g=Duel.SelectTarget(tp,c20366274.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置操作信息，声明将选择的卡加入手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果处理：获取该效果选择的取对象卡，若仍与效果相关则将其加入手牌。
function c20366274.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取这次效果发动时选中的对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象卡以效果原因加入其持有者的手牌。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
