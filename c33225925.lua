--久遠の魔術師ミラ
-- 效果：
-- ①：这张卡召唤成功的场合，以对方场上1张里侧表示的卡为对象发动。把那张对方的卡确认。对方不能对应这个效果的发动把魔法·陷阱卡发动。
function c33225925.initial_effect(c)
	-- ①：这张卡召唤成功的场合，以对方场上1张里侧表示的卡为对象发动。把那张对方的卡确认。对方不能对应这个效果的发动把魔法·陷阱卡发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(33225925,0))  --"确认对方场上盖放的1张卡"
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c33225925.target)
	e1:SetOperation(c33225925.operation)
	c:RegisterEffect(e1)
end
-- 效果发动时的目标处理：先检查是否是指定对象（chkc），对象需为对方场上的里侧表示卡；在发动条件确认（chk==0）时直接允许发动，随后提示玩家选择对方场上1张里侧表示的卡作为对象，并设置连锁限制使对方不能对应发动魔法·陷阱卡。
function c33225925.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsOnField() and chkc:IsFacedown() end
	if chk==0 then return true end
	-- 向当前玩家显示选择提示消息，内容为“请选择一张要确认的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(33225925,1))  --"请选择一张要确认的卡"
	-- 从对方场上（包含魔陷区和怪兽区）选择1张里侧表示的卡作为效果对象，并登记为当前连锁的对象卡。
	local g=Duel.SelectTarget(tp,Card.IsFacedown,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设定本效果发动后的连锁限制：对方玩家不能对应本效果的发动而连锁发动魔法·陷阱卡。
	Duel.SetChainLimit(c33225925.chainlimit)
end
-- 连锁限制判定函数：若试图连锁的玩家是效果发动者本人（tp==rp）则允许连锁；否则仅允许非魔法·陷阱卡的发动（即魔法·陷阱卡不能连锁）。
function c33225925.chainlimit(e,rp,tp)
	return tp==rp or not e:IsHasType(EFFECT_TYPE_ACTIVATE)
end
-- 效果处理时的实际操作：取得效果对象卡，若该卡仍存在于场上、与效果存在关联且仍为里侧表示，则将其给对方玩家确认。
function c33225925.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中登记的第一个（也是唯一一个）对象卡。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsFacedown() then
		-- 将对象卡展示给当前玩家，完成“把那张对方的卡确认”的处理。
		Duel.ConfirmCards(tp,tc)
	end
end
