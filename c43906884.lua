--BF－マイン
-- 效果：
-- 盖放的这张卡被对方的效果破坏时，自己场上有名字带有「黑羽」的怪兽表侧表示存在的场合，给与对方基本分1000分伤害，自己从卡组抽1张卡。
function c43906884.initial_effect(c)
	-- 诱发必发效果，破坏时触发
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(43906884,0))  --"伤害和抽卡"
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_PLAYER_TARGET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCondition(c43906884.con)
	e1:SetTarget(c43906884.tg)
	e1:SetOperation(c43906884.op)
	c:RegisterEffect(e1)
end
-- 检查场上是否存在表侧表示的黑羽怪兽
function c43906884.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x33)
end
-- 效果发动条件：被对方效果破坏且破坏原因包含REASON_EFFECT和REASON_DESTROY，破坏者为对方，卡之前在场上且背面表示，且自己场上有黑羽怪兽
function c43906884.con(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,0x41)==0x41 and rp==1-tp
		and e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
		and e:GetHandler():IsPreviousPosition(POS_FACEDOWN)
		-- 检查自己场上是否存在至少1只表侧表示的黑羽怪兽
		and Duel.IsExistingMatchingCard(c43906884.filter,tp,LOCATION_MZONE,0,1,nil)
end
-- 设置效果处理时的连锁操作信息，包含造成伤害和抽卡
function c43906884.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置对对方造成1000伤害的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,1000)
	-- 设置自己抽1张卡的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 效果处理函数，执行造成伤害和抽卡操作
function c43906884.op(e,tp,eg,ep,ev,re,r,rp)
	-- 再次确认自己场上是否存在黑羽怪兽，若无则不执行效果
	if not Duel.IsExistingMatchingCard(c43906884.filter,tp,LOCATION_MZONE,0,1,nil) then return end
	-- 对对方造成1000点伤害
	Duel.Damage(1-tp,1000,REASON_EFFECT)
	-- 自己从卡组抽1张卡
	Duel.Draw(tp,1,REASON_EFFECT)
end
