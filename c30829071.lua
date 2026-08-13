--驚楽園の大使 ＜Bufo＞
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：这张卡召唤成功时，以自己墓地1张「游乐设施」陷阱卡和对方场上1只怪兽为对象才能发动。那张墓地的卡给那只对方怪兽装备。
-- ②：以给怪兽装备的1张自己的「游乐设施」陷阱卡为对象才能发动。那张卡给1只自己场上的「惊乐」怪兽或者对方场上的表侧表示怪兽装备。这个效果在对方回合也能发动。
function c30829071.initial_effect(c)
	-- ①：这张卡召唤成功时，以自己墓地1张「游乐设施」陷阱卡和对方场上1只怪兽为对象才能发动。那张墓地的卡给那只对方怪兽装备。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(30829071,0))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c30829071.eqtg1)
	e1:SetOperation(c30829071.eqop1)
	c:RegisterEffect(e1)
	-- 这个卡名的②的效果1回合只能使用1次。②：以给怪兽装备的1张自己的「游乐设施」陷阱卡为对象才能发动。那张卡给1只自己场上的「惊乐」怪兽或者对方场上的表侧表示怪兽装备。这个效果在对方回合也能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(30829071,1))
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,30829071)
	e2:SetTarget(c30829071.eqtg2)
	e2:SetOperation(c30829071.eqop2)
	c:RegisterEffect(e2)
end
-- 筛选器：判断卡片是否为「游乐设施」陷阱卡，用于选取自己墓地的可装备对象。
function c30829071.eqfilter(c)
	return c:IsType(TYPE_TRAP) and c:IsSetCard(0x15c)
end
-- ①的发动条件检查：需要自己魔陷区有空位、自己墓地存在「游乐设施」陷阱卡、对方场上有表侧表示怪兽，三个条件同时满足才能发动（chkc时直接返回false，由后续手动选择两个对象）。
function c30829071.eqtg1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 发动条件之一：我方魔陷区必须有空位，才能把墓地陷阱卡装备到对方怪兽身上。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 发动条件之二：自己墓地存在至少1张「游乐设施」陷阱卡可作为装备对象。
		and Duel.IsExistingTarget(c30829071.eqfilter,tp,LOCATION_GRAVE,0,1,nil)
		-- 发动条件之三：对方场上有至少1只表侧表示怪兽可作为装备对象。
		and Duel.IsExistingTarget(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要装备的卡（即墓地的「游乐设施」陷阱卡）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择自己墓地1张「游乐设施」陷阱卡作为效果对象，并加入连锁对象。
	local g1=Duel.SelectTarget(tp,c30829071.eqfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	e:SetLabelObject(g1:GetFirst())
	-- 提示玩家选择效果的对象（对方场上的怪兽）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择对方场上1只表侧表示怪兽作为效果对象。
	local g2=Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息：该效果会使墓地的卡离开墓地，涉及「王家之长眠谷」等互动的分类标记。
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g1,1,0,0)
end
-- ①效果处理：若魔陷区仍有空位，且墓地陷阱和对象怪兽仍合法，则将墓地陷阱卡装备给对象怪兽，并为其设置仅能装备该怪兽的限制效果。
function c30829071.eqop1(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次确认魔陷区有空位，没有空位则终止处理。
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	local ec=e:GetLabelObject()
	-- 获取本连锁的效果对象组（包括选择的墓地陷阱卡和对方怪兽）。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local tc=g:GetFirst()
	if tc==ec then tc=g:GetNext() end
	if ec:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsRelateToEffect(e) and tc:IsControler(1-tp) then
		-- 将墓地中选择的「游乐设施」陷阱卡 ec 装备给对象怪兽 tc。
		Duel.Equip(tp,ec,tc)
		-- ①：那张墓地的卡给那只对方怪兽装备。（通过EFFECT_EQUIP_LIMIT限制该装备卡只能装备给对象怪兽）
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_OWNER_RELATE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(c30829071.eqlimit)
		e1:SetLabelObject(tc)
		ec:RegisterEffect(e1)
	end
end
-- 装备限制判定：装备卡只能装备给效果中被选为对象的怪兽（LabelObject记录的目标）。
function c30829071.eqlimit(e,c)
	return c==e:GetLabelObject()
end
-- ②的取对象筛选器：选择自己场上表侧表示且装备在怪兽身上的「游乐设施」陷阱卡，并确认当前存在可以转移装备的合法新目标。
function c30829071.eqfilter1(c,tp)
	return c:IsSetCard(0x15c) and c:IsType(TYPE_TRAP) and c:IsFaceup() and c:GetEquipTarget()
		-- 额外条件：场上存在满足eqfilter2的怪兽（自己「惊乐」怪兽或对方表侧怪兽），且不能是当前装备卡已经装备的那只怪兽。
		and Duel.IsExistingMatchingCard(c30829071.eqfilter2,tp,LOCATION_MZONE,LOCATION_MZONE,1,c:GetEquipTarget(),tp)
end
-- 新装备目标筛选器：表侧表示，且满足“自己场上的「惊乐」怪兽”或“对方场上的表侧表示怪兽”之一。
function c30829071.eqfilter2(c,tp)
	return c:IsFaceup() and (c:IsSetCard(0x15b) or not c:IsControler(tp))
end
-- ②的取对象处理：选择自己魔陷区一张装备状态且为「游乐设施」陷阱卡为对象，并检查存在可转移装备的合法新目标。
function c30829071.eqtg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_SZONE) and chkc:IsControler(tp) and c30829071.eqfilter1(chkc,tp) end
	-- 发动条件：自己魔陷区存在至少1张满足eqfilter1的装备中「游乐设施」陷阱卡可以作为对象。
	if chk==0 then return Duel.IsExistingTarget(c30829071.eqfilter1,tp,LOCATION_SZONE,0,1,nil,tp) end
	-- 提示玩家选择效果的对象（装备中的「游乐设施」陷阱卡）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择自己魔陷区1张装备中的「游乐设施」陷阱卡作为效果对象。
	local g=Duel.SelectTarget(tp,c30829071.eqfilter1,tp,LOCATION_SZONE,0,1,1,nil,tp)
end
-- ②效果处理：取得对象装备卡，若仍合法，则选择新装备目标，将装备卡转移装备给该目标，并设置新的装备限制。
function c30829071.eqop2(e,tp,eg,ep,ev,re,r,rp)
	-- 取得②效果的对象卡（装备中的「游乐设施」陷阱卡）。
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 提示玩家选择要装备的新目标卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
		-- 选择新装备目标：自己场上的「惊乐」怪兽或对方场上的表侧表示怪兽，排除当前装备的怪兽。
		local g=Duel.SelectMatchingCard(tp,c30829071.eqfilter2,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,tc:GetEquipTarget(),tp)
		local ec=g:GetFirst()
		if ec then
			-- 显示选中新目标的动画，并记录这些卡被选为对象（广义）。
			Duel.HintSelection(g)
			-- 将装备卡 tc 转移装备给新目标 ec。
			Duel.Equip(tp,tc,ec)
			-- ②：那张卡给1只自己场上的「惊乐」怪兽或者对方场上的表侧表示怪兽装备。（通过EFFECT_EQUIP_LIMIT限制该装备卡只能装备给新选择的目标）
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetCode(EFFECT_EQUIP_LIMIT)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			e1:SetValue(c30829071.eqlimit)
			e1:SetLabelObject(ec)
			tc:RegisterEffect(e1)
		end
	end
end
