--エルシャドール・シェキナーガ
-- 效果：
-- 「影依」怪兽＋地属性怪兽
-- 这张卡用融合召唤才能从额外卡组特殊召唤。这个卡名的①的效果1回合只能使用1次。
-- ①：特殊召唤的怪兽的效果发动时才能发动。那个发动无效并破坏。那之后，从自己手卡选1张「影依」卡送去墓地。
-- ②：这张卡被送去墓地的场合，以自己墓地1张「影依」魔法·陷阱卡为对象才能发动。那张卡加入手卡。
function c74822425.initial_effect(c)
	c:EnableReviveLimit()
	-- 设定「影依」融合怪兽的融合素材为「影依」怪兽加地属性怪兽
	aux.AddFusionProcShaddoll(c,ATTRIBUTE_EARTH)
	-- 这张卡用融合召唤才能从额外卡组特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetCode(EFFECT_SPSUMMON_CONDITION)
	e2:SetRange(LOCATION_EXTRA)
	e2:SetValue(c74822425.splimit)
	c:RegisterEffect(e2)
	-- ①：特殊召唤的怪兽的效果发动时才能发动。那个发动无效并破坏。那之后，从自己手卡选1张「影依」卡送去墓地。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(74822425,0))  --"无效并破坏"
	e3:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,74822425)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e3:SetCode(EVENT_CHAINING)
	e3:SetCondition(c74822425.discon)
	e3:SetTarget(c74822425.distg)
	e3:SetOperation(c74822425.disop)
	c:RegisterEffect(e3)
	-- ②：这张卡被送去墓地的场合，以自己墓地1张「影依」魔法·陷阱卡为对象才能发动。那张卡加入手卡。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(74822425,1))  --"加入手卡"
	e4:SetCategory(CATEGORY_TOHAND)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e4:SetTarget(c74822425.thtg)
	e4:SetOperation(c74822425.thop)
	c:RegisterEffect(e4)
end
-- 限制特殊召唤方式只能是融合召唤
function c74822425.splimit(e,se,sp,st)
	return bit.band(st,SUMMON_TYPE_FUSION)==SUMMON_TYPE_FUSION
end
-- 检查是否满足无效并破坏效果的发动条件（特殊召唤的怪兽在场上发动效果，且该发动可以被无效）
function c74822425.discon(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) then return false end
	-- 获取当前发动效果的卡片在发动时的位置
	local loc=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)
	return loc==LOCATION_MZONE and re:IsActiveType(TYPE_MONSTER)
		and re:GetHandler():IsSummonType(SUMMON_TYPE_SPECIAL)
		-- 检查该连锁的发动是否可以被无效
		and Duel.IsChainNegatable(ev)
end
-- 过滤手卡中「影依」卡片的条件函数
function c74822425.filter(c)
	return c:IsSetCard(0x9d)
end
-- 无效并破坏效果的发动准备（检查手卡是否有「影依」卡，并设置无效与破坏的操作信息）
function c74822425.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己手卡中是否存在至少1张「影依」卡作为发动的可行性条件
	if chk==0 then return Duel.IsExistingMatchingCard(c74822425.filter,tp,LOCATION_HAND,0,1,nil) end
	-- 设置在效果处理时将执行“使发动无效”的操作信息
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置在效果处理时将执行“破坏该卡”的操作信息
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 无效并破坏效果的具体处理（无效并破坏，之后从手卡选1张「影依」卡送去墓地）
function c74822425.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 尝试无效该效果的发动，若成功且该卡仍存在则将其破坏
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) and Duel.Destroy(eg,REASON_EFFECT)>0 then
		-- 提示玩家选择要送去墓地的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		-- 让玩家从手卡选择1张「影依」卡
		local g=Duel.SelectMatchingCard(tp,c74822425.filter,tp,LOCATION_HAND,0,1,1,nil)
		if g:GetCount()>0 then
			-- 中断当前效果处理，使后续的送去墓地处理不与破坏同时进行（造成错时点）
			Duel.BreakEffect()
			-- 将选中的「影依」卡因效果送去墓地
			Duel.SendtoGrave(g,REASON_EFFECT)
		end
	end
end
-- 过滤墓地中可以加入手卡的「影依」魔法·陷阱卡的条件函数
function c74822425.thfilter(c)
	return c:IsSetCard(0x9d) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- 回收墓地「影依」魔陷效果的发动准备（选择墓地的目标并设置回收的操作信息）
function c74822425.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c74822425.thfilter(chkc) end
	-- 检查自己墓地是否存在符合条件的「影依」魔法·陷阱卡
	if chk==0 then return Duel.IsExistingTarget(c74822425.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家选择墓地中1张符合条件的「影依」魔法·陷阱卡作为效果的对象
	local g=Duel.SelectTarget(tp,c74822425.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置在效果处理时将执行“将目标卡加入手卡”的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 回收墓地「影依」魔陷效果的具体处理（将选择的目标卡加入手卡）
function c74822425.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在发动时选择的作为效果对象的卡片
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡片因效果加入持有者的手卡
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
