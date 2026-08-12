--No.3 地獄蝉王ローカスト・キング
-- 效果：
-- 3星怪兽×2
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡的表示形式变更的场合才能发动。从自己的手卡·墓地把1只昆虫族怪兽守备表示特殊召唤。
-- ②：场上的怪兽的效果发动时，把这张卡1个超量素材取除，以那1只怪兽为对象才能发动。那只怪兽的效果无效。那之后，选场上1只昆虫族怪兽，守备力上升500或表示形式变更。
function c4997565.initial_effect(c)
	-- 为卡片添加等级为3、需要2只怪兽进行XYZ召唤的手续
	aux.AddXyzProcedure(c,nil,3,2)
	c:EnableReviveLimit()
	-- ①：这张卡的表示形式变更的场合才能发动。从自己的手卡·墓地把1只昆虫族怪兽守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(4997565,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_CHANGE_POS)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,4997565)
	e1:SetTarget(c4997565.sptg)
	e1:SetOperation(c4997565.spop)
	c:RegisterEffect(e1)
	-- ②：场上的怪兽的效果发动时，把这张卡1个超量素材取除，以那1只怪兽为对象才能发动。那只怪兽的效果无效。那之后，选场上1只昆虫族怪兽，守备力上升500或表示形式变更。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(4997565,1))
	e2:SetCategory(CATEGORY_DISABLE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,4997566)
	e2:SetCondition(c4997565.discon)
	e2:SetCost(c4997565.discost)
	e2:SetTarget(c4997565.distg)
	e2:SetOperation(c4997565.disop)
	c:RegisterEffect(e2)
end
-- 设置该卡片的XYZ等级为3
aux.xyz_number[4997565]=3
-- 过滤函数：检查目标卡是否为昆虫族且能特殊召唤到守备表示
function c4997565.spfilter(c,e,tp)
	return c:IsRace(RACE_INSECT) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 判断是否满足①效果的发动条件：场上存在空怪兽区且手牌或墓地有昆虫族怪兽可特殊召唤
function c4997565.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足①效果的发动条件：场上存在空怪兽区
	if chk==0 then return Duel.GetMZoneCount(tp)>0 and
		-- 判断是否满足①效果的发动条件：手牌或墓地存在至少1张满足过滤条件的昆虫族怪兽
		Duel.IsExistingMatchingCard(c4997565.spfilter,tp,LOCATION_GRAVE+LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置连锁操作信息为特殊召唤，目标为手牌或墓地的昆虫族怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE+LOCATION_HAND)
end
-- ①效果的处理函数：若场上存在空怪兽区，则选择一张手牌或墓地的昆虫族怪兽进行守备表示特殊召唤
function c4997565.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否满足①效果的处理条件：场上存在空怪兽区
	if Duel.GetMZoneCount(tp)<=0 then return end
	-- 提示玩家选择要特殊召唤的昆虫族怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手牌或墓地选择一张满足过滤条件的昆虫族怪兽
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c4997565.spfilter),tp,LOCATION_GRAVE+LOCATION_HAND,0,1,1,nil,e,tp)
	if #g==0 then return end
	-- 将所选的昆虫族怪兽以守备表示特殊召唤到场上
	Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
end
-- ②效果的发动条件：发动的是怪兽效果且该效果来自主要怪兽区
function c4997565.discon(e,tp,eg,ep,ev,re,r,rp)
	return re:IsActiveType(TYPE_MONSTER)
		-- 判断是否满足②效果的发动条件：该效果来自主要怪兽区
		and Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)==LOCATION_MZONE
end
-- ②效果的费用支付函数：移除自身1个超量素材作为费用
function c4997565.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 过滤函数：检查目标卡是否为昆虫族且处于表侧表示且守备力大于0或可变更表示形式
function c4997565.cfilter(c)
	return c:IsRace(RACE_INSECT) and c:IsFaceup() and (c:IsDefenseAbove(0) or c:IsCanChangePosition())
end
-- ②效果的目标选择函数：判断是否存在满足条件的昆虫族怪兽，以及目标怪兽是否有效果目标
function c4997565.distg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local tc=re:GetHandler()
	-- 判断是否满足②效果的目标选择条件：场上存在至少1张满足过滤条件的昆虫族怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c4997565.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
		and not tc:IsDisabled() and tc:IsRelateToEffect(re) and tc:IsCanBeEffectTarget(e) end
	-- 设置连锁对象为发动的效果的目标怪兽
	Duel.SetTargetCard(tc)
end
-- ②效果的处理函数：使目标怪兽效果无效，并在之后选择一张昆虫族怪兽使其守备力上升500或变更表示形式
function c4997565.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) and tc:IsCanBeDisabledByEffect(e) then
		-- 使目标怪兽相关的连锁无效化
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		-- 创建一个使目标怪兽效果无效的永续效果
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_DISABLE_EFFECT)
		e1:SetValue(RESET_TURN_SET)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 创建一个使目标怪兽效果被无效的永续效果
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetCode(EFFECT_DISABLE)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
		-- 判断是否满足②效果的后续处理条件：场上存在至少1张满足过滤条件的昆虫族怪兽
		if Duel.IsExistingMatchingCard(c4997565.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) then
			-- 中断当前效果处理，使后续效果视为不同时处理
			Duel.BreakEffect()
			-- 提示玩家选择要操作的昆虫族怪兽
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
			-- 从场上选择一张满足过滤条件的昆虫族怪兽
			local g=Duel.SelectMatchingCard(tp,c4997565.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
			-- 让玩家选择是守备力上升500还是变更表示形式
			local opt=Duel.SelectOption(tp,aux.Stringid(4997565,2),aux.Stringid(4997565,3))  --"守备力上升/表示形式变更"
			if opt==0 then
				-- 创建一个使目标怪兽守备力上升500的效果
				local e3=Effect.CreateEffect(c)
				e3:SetType(EFFECT_TYPE_SINGLE)
				e3:SetCode(EFFECT_UPDATE_DEFENSE)
				e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
				e3:SetReset(RESET_EVENT+RESETS_STANDARD)
				e3:SetValue(500)
				g:GetFirst():RegisterEffect(e3)
			else
				-- 将所选的昆虫族怪兽变更表示形式
				Duel.ChangePosition(g,POS_FACEUP_DEFENSE,POS_FACEDOWN_ATTACK,POS_FACEUP_ATTACK,POS_FACEDOWN_DEFENSE)
			end
		end
	end
end
