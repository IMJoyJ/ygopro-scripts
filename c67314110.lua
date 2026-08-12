--驚楽園の案内人 ＜Comica＞
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：这张卡召唤成功时才能发动。从卡组选1张「游乐设施」陷阱卡在自己的魔法与陷阱区域盖放。
-- ②：以给怪兽装备的1张自己的「游乐设施」陷阱卡为对象才能发动。那张卡给1只自己场上的「惊乐」怪兽或者对方场上的表侧表示怪兽装备。这个效果在对方回合也能发动。
function c67314110.initial_effect(c)
	-- ①：这张卡召唤成功时才能发动。从卡组选1张「游乐设施」陷阱卡在自己的魔法与陷阱区域盖放。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(67314110,0))  --"盖放"
	e1:SetCategory(CATEGORY_SSET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c67314110.settg)
	e1:SetOperation(c67314110.setop)
	c:RegisterEffect(e1)
	-- ②：以给怪兽装备的1张自己的「游乐设施」陷阱卡为对象才能发动。那张卡给1只自己场上的「惊乐」怪兽或者对方场上的表侧表示怪兽装备。这个效果在对方回合也能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(67314110,1))  --"改变装备对象"
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,67314110)
	e2:SetTarget(c67314110.eqtg)
	e2:SetOperation(c67314110.eqop)
	c:RegisterEffect(e2)
end
-- 过滤卡组中可以盖放的「游乐设施」陷阱卡
function c67314110.setfilter(c)
	return c:IsSetCard(0x15c) and c:IsType(TYPE_TRAP) and c:IsSSetable()
end
-- 效果①的发动准备
function c67314110.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己卡组是否存在可盖放的「游乐设施」陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(c67314110.setfilter,tp,LOCATION_DECK,0,1,nil) end
end
-- 效果①的处理
function c67314110.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要盖放的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 从卡组选择1张满足条件的「游乐设施」陷阱卡
	local tc=Duel.SelectMatchingCard(tp,c67314110.setfilter,tp,LOCATION_DECK,0,1,1,nil):GetFirst()
	if tc then
		-- 将选择的卡在自己的魔法与陷阱区域盖放
		Duel.SSet(tp,tc)
	end
end
-- 过滤自己场上已装备给怪兽的表侧表示「游乐设施」陷阱卡，且场上存在其他可装备的怪兽
function c67314110.eqfilter1(c,tp)
	return c:IsSetCard(0x15c) and c:IsType(TYPE_TRAP) and c:IsFaceup() and c:GetEquipTarget()
		-- 检查场上是否存在除当前装备对象以外的、可作为新装备对象的怪兽
		and Duel.IsExistingMatchingCard(c67314110.eqfilter2,0,LOCATION_MZONE,LOCATION_MZONE,1,c:GetEquipTarget(),tp)
end
-- 过滤可作为新装备对象的怪兽（自己场上的「惊乐」怪兽或对方场上的表侧表示怪兽）
function c67314110.eqfilter2(c,tp)
	return c:IsFaceup() and (c:IsSetCard(0x15b) or not c:IsControler(tp))
end
-- 效果②的发动准备
function c67314110.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_SZONE) and chkc:IsControler(tp) and c67314110.eqfilter1(chkc,tp) end
	-- 检查自己场上是否存在可作为效果对象的、已装备给怪兽的「游乐设施」陷阱卡
	if chk==0 then return Duel.IsExistingTarget(c67314110.eqfilter1,tp,LOCATION_SZONE,0,1,nil,tp) end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择1张已装备给怪兽的自己的「游乐设施」陷阱卡作为效果对象
	local g=Duel.SelectTarget(tp,c67314110.eqfilter1,tp,LOCATION_SZONE,0,1,1,nil,tp)
end
-- 效果②的处理
function c67314110.eqop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的「游乐设施」陷阱卡
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 提示玩家选择要装备的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
		-- 选择1只除原装备怪兽以外的、自己场上的「惊乐」怪兽或对方场上的表侧表示怪兽
		local g=Duel.SelectMatchingCard(tp,c67314110.eqfilter2,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,tc:GetEquipTarget(),tp)
		local ec=g:GetFirst()
		if ec then
			-- 为选择的怪兽显示被选为对象的动画效果
			Duel.HintSelection(g)
			-- 将作为对象的「游乐设施」陷阱卡装备给新选择的怪兽
			Duel.Equip(tp,tc,ec)
			-- 那张卡给1只自己场上的「惊乐」怪兽或者对方场上的表侧表示怪兽装备。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetCode(EFFECT_EQUIP_LIMIT)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			e1:SetValue(c67314110.eqlimit)
			e1:SetLabelObject(ec)
			tc:RegisterEffect(e1)
		end
	end
end
-- 装备限制函数，使该「游乐设施」陷阱卡只能装备给新选择的怪兽
function c67314110.eqlimit(e,c)
	return c==e:GetLabelObject()
end
