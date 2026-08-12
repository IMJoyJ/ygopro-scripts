--海神の依代
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：以自己墓地1只水属性怪兽为对象才能发动。从以下效果选1个适用。这个回合，自己不是水属性怪兽不能特殊召唤。
-- ●直到结束阶段，这张卡变成和作为对象的怪兽相同等级，当作同名卡使用。
-- ●场上有「海」存在的场合，作为对象的怪兽守备表示特殊召唤。
-- ②：把墓地的这张卡除外，以自己墓地1张「海」为对象才能发动。那张卡加入手卡。
function c57511992.initial_effect(c)
	-- 记录这张卡上记载着卡名「海」（卡号22702055）
	aux.AddCodeList(c,22702055)
	-- ①：以自己墓地1只水属性怪兽为对象才能发动。从以下效果选1个适用。这个回合，自己不是水属性怪兽不能特殊召唤。●直到结束阶段，这张卡变成和作为对象的怪兽相同等级，当作同名卡使用。●场上有「海」存在的场合，作为对象的怪兽守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(57511992,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,57511992)
	e1:SetTarget(c57511992.target)
	e1:SetOperation(c57511992.operation)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外，以自己墓地1张「海」为对象才能发动。那张卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,57511993)
	-- 将墓地的这张卡除外作为发动效果的代价
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c57511992.thtg)
	e2:SetOperation(c57511992.thop)
	c:RegisterEffect(e2)
end
-- 过滤自己墓地中满足等级/卡名改变条件或可守备表示特殊召唤的水属性怪兽
function c57511992.tgfilter(c,e,tp,ec,spchk)
	return c:IsAttribute(ATTRIBUTE_WATER)
		and (c:IsLevelAbove(1) and ec:IsLevelAbove(1) and (not c:IsLevel(ec:GetLevel()) or not c:IsCode(ec:GetCode()))
			or spchk and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE))
end
-- ①号效果的发动准备与选择墓地的水属性怪兽作为对象
function c57511992.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	-- 检查场上是否存在「海」且自己场上有空余的怪兽区域
	local spchk=Duel.IsEnvironment(22702055) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c57511992.tgfilter(chkc,e,tp,c,spchk) end
	-- 检查自己墓地是否存在可作为效果对象的水属性怪兽
	if chk==0 then return Duel.IsExistingTarget(c57511992.tgfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp,c,spchk) end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 玩家选择墓地的一只水属性怪兽作为效果对象
	Duel.SelectTarget(tp,c57511992.tgfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp,c,spchk)
end
-- ①号效果的处理，根据条件让玩家选择适用其中一个效果，并适用特殊召唤限制
function c57511992.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取作为效果对象的水属性怪兽
	local tc=Duel.GetFirstTarget()
	local b1=tc:IsRelateToEffect(e) and c:IsRelateToEffect(e) and c:IsFaceup() and c:IsLevelAbove(1)
		and tc:IsLevelAbove(1) and (not c:IsLevel(tc:GetLevel()) or not c:IsCode(tc:GetCode()))
	-- 检查分支效果2（特殊召唤）的适用条件：对象卡片仍存在、场上有「海」且有空余怪兽区域
	local b2=tc:IsRelateToEffect(e) and Duel.IsEnvironment(22702055) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查对象怪兽是否不受王家长眠之谷影响且可以守备表示特殊召唤
		and aux.NecroValleyFilter()(tc) and tc:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
	if b1 or b2 then
		local s
		if b1 and b2 then
			-- 两个分支效果都满足时，让玩家选择适用“改变卡名和等级”或“特殊召唤”
			s=Duel.SelectOption(tp,aux.Stringid(57511992,1),aux.Stringid(57511992,2))  --"改变卡名和等级/特殊召唤"
		elseif b1 then
			-- 仅满足分支效果1时，玩家只能选择“改变卡名和等级”
			s=Duel.SelectOption(tp,aux.Stringid(57511992,1))  --"改变卡名和等级"
		else
			-- 仅满足分支效果2时，玩家只能选择“特殊召唤”
			s=Duel.SelectOption(tp,aux.Stringid(57511992,2))+1  --"特殊召唤"
		end
		if s==0 then
			-- ●直到结束阶段，这张卡变成和作为对象的怪兽相同等级，当作同名卡使用。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CHANGE_CODE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			e1:SetValue(tc:GetCode())
			c:RegisterEffect(e1)
			local e2=e1:Clone()
			e2:SetCode(EFFECT_CHANGE_LEVEL)
			e2:SetValue(tc:GetLevel())
			c:RegisterEffect(e2)
		end
		if s==1 then
			-- 将作为对象的怪兽守备表示特殊召唤
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
		end
	end
	-- 这个回合，自己不是水属性怪兽不能特殊召唤。/ ②：把墓地的这张卡除外，以自己墓地1张「海」为对象才能发动。那张卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c57511992.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册本回合不能特殊召唤水属性以外怪兽的限制效果
	Duel.RegisterEffect(e1,tp)
end
-- 限制玩家不能特殊召唤水属性以外的怪兽
function c57511992.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsAttribute(ATTRIBUTE_WATER)
end
-- 过滤墓地中可以加入手牌的「海」
function c57511992.thfilter(c)
	return c:IsCode(22702055) and c:IsAbleToHand()
end
-- ②号效果的发动准备与选择墓地的「海」作为对象
function c57511992.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c57511992.thfilter(chkc) end
	-- 检查自己墓地是否存在可作为效果对象的「海」
	if chk==0 then return Duel.IsExistingTarget(c57511992.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 玩家选择墓地的一张「海」作为效果对象
	local g=Duel.SelectTarget(tp,c57511992.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置效果处理信息为将选中的卡片加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- ②号效果的处理，将作为对象的卡加入手牌
function c57511992.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的「海」
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将作为对象的卡片加入手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
