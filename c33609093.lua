--戦華史略－十万之矢
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：以对方场上1只表侧表示怪兽和自己场上1只「战华」怪兽为对象才能发动。直到回合结束时，那只对方怪兽的攻击力变成一半，那只自己怪兽的攻击力上升那个数值。
-- ②：自己场上的「战华」怪兽的属性是2种类以上，这张卡被送去墓地的场合才能发动。从手卡·卡组把「战华史略-十万之矢」以外的1张「战华」永续魔法·永续陷阱卡在自己场上表侧表示放置。
function c33609093.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 这个卡名的①②的效果1回合各能使用1次。①：以对方场上1只表侧表示怪兽和自己场上1只「战华」怪兽为对象才能发动。直到回合结束时，那只对方怪兽的攻击力变成一半，那只自己怪兽的攻击力上升那个数值。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(33609093,0))
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,33609093)
	e2:SetTarget(c33609093.atktg)
	e2:SetOperation(c33609093.atkop)
	c:RegisterEffect(e2)
	-- ②：自己场上的「战华」怪兽的属性是2种类以上，这张卡被送去墓地的场合才能发动。从手卡·卡组把「战华史略-十万之矢」以外的1张「战华」永续魔法·永续陷阱卡在自己场上表侧表示放置。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(33609093,1))
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCountLimit(1,33609094)
	e3:SetCondition(c33609093.tfcon)
	e3:SetTarget(c33609093.tftg)
	e3:SetOperation(c33609093.tfop)
	c:RegisterEffect(e3)
end
-- 定义过滤函数，筛选自己场上表侧表示且属于「战华」系列的怪兽，用于选择①的自己怪兽对象。
function c33609093.atkfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x137)
end
-- 效果①发动时的条件检查：若chkc非nil则返回false；在chk==0时确认对方场上有攻击力>0的表侧表示怪兽且自己场上有表侧表示「战华」怪兽，满足才可发动。
function c33609093.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 检查对方场上是否存在1只以上攻击力不为0的表侧表示怪兽，作为①的对方怪兽对象候补。
	if chk==0 then return Duel.IsExistingTarget(aux.nzatk,tp,0,LOCATION_MZONE,1,nil)
		-- 检查自己场上是否存在1只以上表侧表示「战华」怪兽，作为①的自己怪兽对象候补；两者同时存在时效果发动条件成立。
		and Duel.IsExistingTarget(c33609093.atkfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 向玩家发出选择对方怪兽的提示消息，提示内容为“请选择对方的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPPO)  --"请选择对方的卡"
	-- 从对方场上选择1只攻击力大于0的表侧表示怪兽，将其指定为效果对象并登记到连锁信息中。
	local g=Duel.SelectTarget(tp,aux.nzatk,tp,0,LOCATION_MZONE,1,1,nil)
	e:SetLabelObject(g:GetFirst())
	-- 向玩家发出选择自己怪兽的提示消息，提示内容为“请选择自己的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SELF)  --"请选择自己的卡"
	-- 从自己场上选择1只表侧表示「战华」怪兽，将其指定为效果对象并登记到连锁信息中。
	Duel.SelectTarget(tp,c33609093.atkfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果①处理时：获取对方和自己两只对象怪兽，若对方怪兽仍与效果相关且表侧表示，则将其攻击力变为原攻击力的一半（向上取整）；若自己怪兽也仍合法，则让其攻击力上升相同的数值，该变化持续到回合结束。
function c33609093.atkop(e,tp,eg,ep,ev,re,r,rp)
	local hc=e:GetLabelObject()
	-- 获取当前连锁中记录的效果对象卡组，其中包含发动时选择的对方怪兽和自己怪兽。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local tc=g:GetFirst()
	if tc==hc then tc=g:GetNext() end
	if hc:IsRelateToEffect(e) and hc:IsFaceup() then
		local atk=hc:GetAttack()
		-- 直到回合结束时，那只对方怪兽的攻击力变成一半。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(math.ceil(atk/2))
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		hc:RegisterEffect(e1)
		if tc:IsRelateToEffect(e) and tc:IsFaceup() then
			local e2=e1:Clone()
			e2:SetCode(EFFECT_UPDATE_ATTACK)
			tc:RegisterEffect(e2)
		end
	end
end
-- 定义过滤函数，筛选自己场上表侧表示且属于「战华」系列的怪兽，用于②的属性种类数统计。
function c33609093.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x137)
end
-- 效果②发动条件判断：自己场上的表侧表示「战华」怪兽的属性种类在2种以上，满足该条件时才允许发动。
function c33609093.tfcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上所有表侧表示且属于「战华」系列的怪兽，组成一个卡片组用于统计属性。
	local g=Duel.GetMatchingGroup(c33609093.cfilter,tp,LOCATION_MZONE,0,nil)
	-- 统计上述「战华」怪兽的属性种类数，若大于1（即2种类以上）则②的发动条件成立。
	return aux.GetAttributeCount(g)>1
end
-- 定义效果②可放置的卡牌过滤条件：从手卡·卡组选出的是「战华」系列的永续魔法·永续陷阱卡，且卡名不是「战华史略-十万之矢」，不是禁止卡，并且场上不存在同名卡。
function c33609093.tffilter(c,tp)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsType(TYPE_CONTINUOUS) and c:IsSetCard(0x137) and not c:IsCode(33609093)
		and not c:IsForbidden() and c:CheckUniqueOnField(tp)
end
-- 效果②发动时的合法条件检查：确认自己魔陷区有空位，且手卡·卡组中存在满足条件的「战华」永续魔法·永续陷阱卡，才可发动。
function c33609093.tftg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己魔陷区是否有可以放置卡片的空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查手卡·卡组中是否存在1张以上满足条件的「战华」永续魔法·永续陷阱卡；与魔陷区空位条件同时满足时②可发动。
		and Duel.IsExistingMatchingCard(c33609093.tffilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,tp) end
end
-- 效果②处理时：从手卡·卡组选择符合条件的「战华」永续魔法·永续陷阱卡，以表侧表示放置到自己的魔陷区。
function c33609093.tfop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次确认自己魔陷区有空位，若没有空位则直接结束处理。
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	-- 向玩家发出选择要放置到场上的卡的提示消息，提示内容为“请选择要放置到场上的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
	-- 从手卡·卡组中选出1张满足条件的「战华」永续魔法·永续陷阱卡并获取该卡。
	local tc=Duel.SelectMatchingCard(tp,c33609093.tffilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,tp):GetFirst()
	if tc then
		-- 将选出的卡以表侧表示放置到自己的魔陷区，并立即适用该卡的效果。
		Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
	end
end
