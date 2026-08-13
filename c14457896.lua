--寄生虫パラノイド
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：以场上1只表侧表示怪兽为对象才能发动。这张卡从手卡当作装备卡使用给那只怪兽装备。装备怪兽种族变成昆虫族，不能向昆虫族怪兽攻击，昆虫族怪兽为对象发动的装备怪兽的效果无效化。这个效果在对方回合也能发动。
-- ②：当作装备卡使用的这张卡被送去墓地的场合才能发动。从手卡把1只7星以上的昆虫族怪兽无视召唤条件特殊召唤。
function c14457896.initial_effect(c)
	-- 这个卡名的①的效果1回合只能使用1次。①：以场上1只表侧表示怪兽为对象才能发动。这张卡从手卡当作装备卡使用给那只怪兽装备。装备怪兽种族变成昆虫族，不能向昆虫族怪兽攻击，昆虫族怪兽为对象发动的装备怪兽的效果无效化。这个效果在对方回合也能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(14457896,0))
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,14457896)
	e1:SetTarget(c14457896.eqtg)
	e1:SetOperation(c14457896.eqop)
	c:RegisterEffect(e1)
	-- ②：当作装备卡使用的这张卡被送去墓地的场合才能发动。从手卡把1只7星以上的昆虫族怪兽无视召唤条件特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(14457896,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCondition(c14457896.spcon)
	e2:SetTarget(c14457896.sptg)
	e2:SetOperation(c14457896.spop)
	c:RegisterEffect(e2)
end
-- ①效果的发动目标选择函数：选择场上1只表侧表示怪兽作为对象，并确认自己魔陷区有空位且场上存在表侧表示怪兽可供选择。
function c14457896.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	-- 发动条件检查：自己的魔陷区必须存在空闲区域，否则无法发动。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 发动条件检查：场上必须存在至少1只表侧表示怪兽可以作为装备对象。
		and Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 给玩家显示“请选择要装备的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 令玩家从双方场上选择1只表侧表示怪兽，并将其登记为这次连锁的装备对象。
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
-- ①效果的发动处理：确认这张卡和对象仍合法后，将这张卡装备给对象怪兽；随后给这张卡注册装备对象限制、使装备怪兽种族变为昆虫族、禁止装备怪兽选择昆虫族怪兽为攻击对象的效果；若对象为攻击怪兽且其攻击对象是表侧昆虫族怪兽则无效攻击；再注册持续效果以无效化装备怪兽发动的以昆虫族怪兽为对象的取对象效果。
function c14457896.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	if c:IsLocation(LOCATION_MZONE) and c:IsFacedown() then return end
	-- 取得发动时选择的装备对象怪兽。
	local tc=Duel.GetFirstTarget()
	-- 若魔陷区没有空位、对象变成里侧表示或对象与效果已无关联，则不能装备，转入失败处理。
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 or tc:IsFacedown() or not tc:IsRelateToEffect(e) then
		-- 装备条件不满足时，将这张卡从手卡送去墓地。
		Duel.SendtoGrave(c,REASON_EFFECT)
		return
	end
	-- 将这张卡作为装备卡装备给对象怪兽。
	Duel.Equip(tp,c,tc)
	-- 这张卡从手卡当作装备卡使用给那只怪兽装备（限定只能装备给发动时选择的那只怪兽）。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EQUIP_LIMIT)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e1:SetValue(c14457896.eqlimit)
	e1:SetLabelObject(tc)
	c:RegisterEffect(e1)
	-- 装备怪兽种族变成昆虫族。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_CHANGE_RACE)
	e2:SetValue(RACE_INSECT)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e2)
	-- 不能向昆虫族怪兽攻击。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e3:SetValue(c14457896.atlimit)
	e3:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e3)
	-- 若被装备的怪兽正是当前发动攻击的怪兽，则额外检查其攻击对象。
	if tc==Duel.GetAttacker() then
		local bc=tc:GetBattleTarget()
		if bc~=nil and bc:IsFaceup() and bc:IsRace(RACE_INSECT) then
			-- 无效该攻击（使攻击不成立）。
			Duel.NegateAttack()
		end
	end
	-- 昆虫族怪兽为对象发动的装备怪兽的效果无效化。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_CHAIN_SOLVING)
	e4:SetRange(LOCATION_SZONE)
	e4:SetLabelObject(tc)
	e4:SetCondition(c14457896.discon)
	e4:SetOperation(c14457896.disop)
	e4:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e4)
end
-- 装备限制函数：这张卡仅能装备给记录在标签中的对象怪兽，即发动时选择的那只怪兽。
function c14457896.eqlimit(e,c)
	return c==e:GetLabelObject()
end
-- 攻击对象限制函数：表侧表示的昆虫族怪兽不能被选择为攻击对象。
function c14457896.atlimit(e,c)
	return c:IsRace(RACE_INSECT) and c:IsFaceup()
end
-- 无效化判定中的怪兽过滤函数：用于检查连锁目标中是否存在表侧表示且与发动效果相关的昆虫族怪兽。
function c14457896.disfilter(c,re)
	return c:IsType(TYPE_MONSTER) and c:IsFaceup() and c:IsRace(RACE_INSECT) and c:IsRelateToEffect(re)
end
-- 无效化发动条件：装备对象发动了取对象效果，且该效果的目标中包含表侧昆虫族怪兽，并且该连锁可以被无效时，才满足条件。
function c14457896.discon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	local rc=re:GetHandler()
	if not tc or rc~=tc then return false end
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	-- 取得当前连锁的效果对象卡组。
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	-- 确认对象卡组中存在符合条件的昆虫族怪兽，且当前连锁能够被无效。
	return g and g:IsExists(c14457896.disfilter,1,nil,re) and Duel.IsChainNegatable(ev)
end
-- 无效化效果的处理函数：将满足条件的连锁效果无效。
function c14457896.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 执行无效该连锁效果。
	Duel.NegateEffect(ev)
end
-- ②的发动条件：这张卡必须是在作为装备卡期间从魔陷区被送去墓地，且存在过装备对象（即曾装备过怪兽）。
function c14457896.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_SZONE) and c:GetPreviousEquipTarget()
end
-- 特殊召唤的候选卡过滤函数：手卡中满足昆虫族、等级7以上、是怪兽且可以被无视召唤条件特殊召唤的卡。
function c14457896.spfilter(c,e,tp)
	return c:IsRace(RACE_INSECT) and c:IsLevelAbove(7) and c:IsType(TYPE_MONSTER) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
-- ②的发动时点检查：自己主要怪兽区有空位，且手卡存在1只符合条件的7星以上昆虫族怪兽，才能发动。
function c14457896.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己主要怪兽区是否有空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡是否存在符合条件的昆虫族怪兽。
		and Duel.IsExistingMatchingCard(c14457896.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 将本次效果的操作信息设置为“从手卡特殊召唤1只怪兽”，供系统及后续效果检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- ②效果处理：若主要怪兽区仍有空位，则提示玩家选择手卡1只7星以上的昆虫族怪兽，并将其无视召唤条件以表侧表示特殊召唤到自己场上。
function c14457896.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 主要怪兽区无空位时，不进行特殊召唤并终止处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡选择1只符合条件的昆虫族怪兽（7星以上）。
	local g=Duel.SelectMatchingCard(tp,c14457896.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽无视召唤条件、以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(g,0,tp,tp,true,false,POS_FACEUP)
	end
end
