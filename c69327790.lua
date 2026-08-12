--烈風帝ライザー
-- 效果：
-- 这张卡可以把1只上级召唤的怪兽解放作上级召唤。
-- ①：这张卡上级召唤成功的场合，以场上1张卡和自己或者对方的墓地1张卡为对象发动。那些卡用喜欢的顺序回到持有者卡组最上面。这张卡把风属性怪兽解放作上级召唤成功的场合，那个时候的效果加上以下效果。
-- ●可以以场上1张卡为对象回到持有者手卡。
function c69327790.initial_effect(c)
	-- 这张卡可以把1只上级召唤的怪兽解放作上级召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(69327790,0))  --"把1只上级召唤的怪兽解放作上级召唤"
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SUMMON_PROC)
	e1:SetCondition(c69327790.otcon)
	e1:SetOperation(c69327790.otop)
	e1:SetValue(SUMMON_TYPE_ADVANCE)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_SET_PROC)
	c:RegisterEffect(e2)
	-- ①：这张卡上级召唤成功的场合，以场上1张卡和自己或者对方的墓地1张卡为对象发动。那些卡用喜欢的顺序回到持有者卡组最上面。这张卡把风属性怪兽解放作上级召唤成功的场合，那个时候的效果加上以下效果。●可以以场上1张卡为对象回到持有者手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(69327790,1))  --"返回卡组最上面"
	e3:SetCategory(CATEGORY_TODECK)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCondition(c69327790.tdcon)
	e3:SetTarget(c69327790.tdtg)
	e3:SetOperation(c69327790.tdop)
	c:RegisterEffect(e3)
	-- 这张卡把风属性怪兽解放作上级召唤成功的场合，那个时候的效果加上以下效果。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_MATERIAL_CHECK)
	e4:SetValue(c69327790.valcheck)
	e4:SetLabelObject(e3)
	c:RegisterEffect(e4)
end
-- 过滤场上上级召唤成功的怪兽
function c69327790.otfilter(c)
	return c:IsSummonType(SUMMON_TYPE_ADVANCE)
end
-- 上级召唤规则效果的条件：自身等级在7星以上且场上有满足条件的可解放怪兽
function c69327790.otcon(e,c,minc)
	if c==nil then return true end
	-- 获取场上所有上级召唤成功的怪兽组
	local mg=Duel.GetMatchingGroup(c69327790.otfilter,0,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 判断自身等级是否在7星以上，且场上是否存在1只可解放的上级召唤怪兽
	return c:IsLevelAbove(7) and minc<=1 and Duel.CheckTribute(c,1,1,mg)
end
-- 上级召唤规则效果的操作：选择并解放1只上级召唤的怪兽
function c69327790.otop(e,tp,eg,ep,ev,re,r,rp,c)
	-- 获取场上所有上级召唤成功的怪兽组
	local mg=Duel.GetMatchingGroup(c69327790.otfilter,0,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 玩家选择1只上级召唤的怪兽作为祭品
	local sg=Duel.SelectTribute(tp,c,1,1,mg)
	c:SetMaterial(sg)
	-- 解放选中的怪兽作为上级召唤的素材
	Duel.Release(sg,REASON_SUMMON+REASON_MATERIAL)
end
-- 效果发动条件：这张卡上级召唤成功
function c69327790.tdcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_ADVANCE)
end
-- 效果的目标选择：选择场上1张卡和双方墓地1张卡作为对象，若满足风属性解放条件则可追加选择场上1张卡
function c69327790.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then return true end
	local g1=nil
	-- 判断场上是否存在可以作为对象的卡
	if Duel.IsExistingTarget(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
		-- 判断双方墓地是否存在可以作为对象的卡
		and Duel.IsExistingTarget(nil,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil) then
		-- 提示玩家选择要返回卡组的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
		-- 选择场上1张卡作为效果对象
		g1=Duel.SelectTarget(tp,nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
		-- 提示玩家选择要返回卡组的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
		-- 选择双方墓地1张卡作为效果对象
		local g2=Duel.SelectTarget(tp,nil,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil)
		e:SetLabelObject(g2:GetFirst())
		g1:Merge(g2)
		-- 设置效果处理信息：将选中的2张卡送回卡组
		Duel.SetOperationInfo(0,CATEGORY_TODECK,g1,2,0,0)
	end
	if e:GetLabel()==1
		-- 判断场上是否存在除已被选为对象的卡以外、可以回到手牌的卡
		and Duel.IsExistingTarget(Card.IsAbleToHand,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,g1)
		-- 询问玩家是否发动追加效果（将场上1张卡回到手牌）
		and Duel.SelectYesNo(tp,aux.Stringid(69327790,2)) then  --"是否要选择场上1张卡回到手卡？"
		e:SetCategory(CATEGORY_TODECK+CATEGORY_TOHAND)
		-- 提示玩家选择要返回手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
		-- 选择场上1张卡作为返回手牌的效果对象
		local g3=Duel.SelectTarget(tp,Card.IsAbleToHand,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,g1)
		-- 设置效果处理信息：将选中的1张卡送回手牌
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,g3,1,0,0)
	else
		e:SetCategory(CATEGORY_TODECK)
	end
end
-- 效果处理：将选中的卡以自选顺序放回卡组最上方，若满足条件则将另一张卡送回手牌
function c69327790.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取要送回卡组的卡片组
	local ex,g1=Duel.GetOperationInfo(0,CATEGORY_TODECK)
	-- 获取要送回手牌 of the card group
	local ex2,g2=Duel.GetOperationInfo(0,CATEGORY_TOHAND)
	if g1 then
		local sg1=g1:Filter(Card.IsRelateToEffect,nil,e)
		-- 将仍存在于场上/墓地的对象卡送回持有者卡组最上方，并判断是否成功送回了2张卡
		if sg1:GetCount()>0 and Duel.SendtoDeck(sg1,nil,SEQ_DECKTOP,REASON_EFFECT)>1 then
			local gc=e:GetLabelObject()
			local fc=sg1:GetFirst()
			if fc==gc then fc=sg1:GetNext() end
			if fc:GetControler()==gc:GetControler() and fc:IsLocation(LOCATION_DECK) and gc:IsLocation(LOCATION_DECK) then
				-- 让玩家选择哪张卡放在最上面（决定返回卡组的顺序）
				local op=Duel.SelectOption(tp,aux.Stringid(69327790,3),aux.Stringid(69327790,4))  --"场上的卡放在卡组最上面/墓地的卡放在卡组最上面"
				if op==0 then
					-- 将场上原本存在的卡移动到卡组最上方
					Duel.MoveSequence(fc,SEQ_DECKTOP)
				else
					-- 将墓地原本存在的卡移动到卡组最上方
					Duel.MoveSequence(gc,SEQ_DECKTOP)
				end
			end
		end
	end
	if e:GetLabel()==1 and g2 then
		local tc=g2:GetFirst()
		if tc:IsRelateToEffect(e) then
			-- 中断当前效果处理，使后续的返回手牌处理不与返回卡组同时进行
			Duel.BreakEffect()
			-- 将选中的场上的卡送回持有者手牌
			Duel.SendtoHand(g2,nil,REASON_EFFECT)
		end
	end
end
-- 检查上级召唤的素材中是否存在风属性怪兽，并为效果注册相应的标记值
function c69327790.valcheck(e,c)
	local g=c:GetMaterial()
	if g:IsExists(Card.IsAttribute,1,nil,ATTRIBUTE_WIND) then
		e:GetLabelObject():SetLabel(1)
	else
		e:GetLabelObject():SetLabel(0)
	end
end
