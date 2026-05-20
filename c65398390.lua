--焔聖騎士将－オリヴィエ
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：有装备卡装备的这张卡的攻击宣言时，以场上1张表侧表示的卡为对象才能发动。那张卡破坏。
-- ②：以自己场上1只战士族怪兽为对象才能发动。这张卡当作调整使用从墓地特殊召唤，作为对象的自己怪兽当作攻击力上升500的装备卡使用给这张卡装备。这个效果在这张卡送去墓地的回合不能发动。
function c65398390.initial_effect(c)
	-- 添加同调召唤手续：调整＋调整以外的怪兽1只以上
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：有装备卡装备的这张卡的攻击宣言时，以场上1张表侧表示的卡为对象才能发动。那张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(65398390,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCondition(c65398390.descon)
	e1:SetTarget(c65398390.destg)
	e1:SetOperation(c65398390.desop)
	c:RegisterEffect(e1)
	-- ②：以自己场上1只战士族怪兽为对象才能发动。这张卡当作调整使用从墓地特殊召唤，作为对象的自己怪兽当作攻击力上升500的装备卡使用给这张卡装备。这个效果在这张卡送去墓地的回合不能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(65398390,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,65398390)
	-- 设置发动条件：这张卡送去墓地的回合不能发动
	e2:SetCondition(aux.exccon)
	e2:SetTarget(c65398390.sptg)
	e2:SetOperation(c65398390.spop)
	c:RegisterEffect(e2)
end
c65398390.treat_itself_tuner=true
-- 效果①的发动条件：自身有装备卡装备
function c65398390.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetEquipCount()>0
end
-- 效果①的靶向/目标选择：以场上1张表侧表示的卡为对象
function c65398390.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsFaceup() end
	-- 检查场上是否存在可以作为对象的表侧表示卡片
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 玩家选择1张表侧表示的卡作为效果对象
	local g=Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置效果处理信息：破坏选中的卡片
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果①的处理：破坏作为对象的卡
function c65398390.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果对象
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 破坏该卡
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- 过滤条件：自己场上表侧表示的战士族怪兽
function c65398390.eqfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_WARRIOR)
end
-- 效果②的靶向/目标选择：以自己场上1只战士族怪兽为对象
function c65398390.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c65398390.eqfilter(chkc) end
	-- 检查自己场上是否有怪兽区域和魔法与陷阱区域的空位，以及自身是否能特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查自己场上是否存在满足条件的战士族怪兽
		and Duel.IsExistingTarget(c65398390.eqfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择要装备的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 玩家选择自己场上1只战士族怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c65398390.eqfilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置效果处理信息：特殊召唤自身
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 效果②的处理：特殊召唤自身并当作调整，将对象怪兽作为装备卡装备
function c65398390.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果对象（要装备的战士族怪兽）
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) then
		-- 尝试将自身以表侧表示特殊召唤（分步处理）
		local res=Duel.SpecialSummonStep(c,0,tp,tp,false,false,POS_FACEUP)
		if res then
			-- 这张卡当作调整使用从墓地特殊召唤
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_ADD_TYPE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			e1:SetValue(TYPE_TUNER)
			c:RegisterEffect(e1)
		end
		-- 完成特殊召唤的最终处理
		Duel.SpecialSummonComplete()
		if res and tc:IsRelateToEffect(e) and tc:IsControler(tp) then
			-- 将作为对象的怪兽装备给这张卡，若装备失败则结束处理
			if not Duel.Equip(tp,tc,c,false) then return end
			-- 作为对象的自己怪兽当作……装备卡使用给这张卡装备
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetProperty(EFFECT_FLAG_OWNER_RELATE)
			e2:SetCode(EFFECT_EQUIP_LIMIT)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			e2:SetLabelObject(c)
			e2:SetValue(c65398390.eqlimit)
			tc:RegisterEffect(e2)
			-- 攻击力上升500的装备卡使用
			local e3=Effect.CreateEffect(tc)
			e3:SetType(EFFECT_TYPE_EQUIP)
			e3:SetCode(EFFECT_UPDATE_ATTACK)
			e3:SetValue(500)
			e3:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e3)
		end
	end
end
-- 装备限制：只能装备给这张卡
function c65398390.eqlimit(e,c)
	return c==e:GetLabelObject()
end
