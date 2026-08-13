--BF－マイン
-- 效果：
-- 盖放的这张卡被对方的效果破坏时，自己场上有名字带有「黑羽」的怪兽表侧表示存在的场合，给与对方基本分1000分伤害，自己从卡组抽1张卡。
function c43906884.initial_effect(c)
	-- 盖放的这张卡被对方的效果破坏时，自己场上有名字带有「黑羽」的怪兽表侧表示存在的场合，给与对方基本分1000分伤害，自己从卡组抽1张卡。
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
-- 筛选自己场上表侧表示且名字带有「黑羽」字段（0x33）的怪兽卡。
function c43906884.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x33)
end
-- 伤害/抽卡的发动条件：这张卡被对方的效果破坏，且破坏前是覆盖在场上，并且自己场上有表侧表示「黑羽」怪兽。
function c43906884.con(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,0x41)==0x41 and rp==1-tp
		and e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
		and e:GetHandler():IsPreviousPosition(POS_FACEDOWN)
		-- 确认自己场上存在至少1张表侧表示的名字带有「黑羽」的怪兽，作为效果发动的追加条件。
		and Duel.IsExistingMatchingCard(c43906884.filter,tp,LOCATION_MZONE,0,1,nil)
end
-- 效果发动时无需取对象，chk==0直接允许发动，并登记即将造成伤害和抽卡的操作信息。
function c43906884.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 登记将对对方玩家造成1000分效果伤害的操作信息（不取对象）。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,1000)
	-- 登记自己将抽1张卡的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 效果处理时再次确认自己场上仍有表侧表示「黑羽」怪兽，然后给对方造成1000伤害，自己抽1张卡。
function c43906884.op(e,tp,eg,ep,ev,re,r,rp)
	-- 若效果处理时自己场上已没有表侧表示「黑羽」怪兽，则整个效果不适用。
	if not Duel.IsExistingMatchingCard(c43906884.filter,tp,LOCATION_MZONE,0,1,nil) then return end
	-- 给对方玩家造成1000分效果伤害。
	Duel.Damage(1-tp,1000,REASON_EFFECT)
	-- 自己从卡组抽1张卡。
	Duel.Draw(tp,1,REASON_EFFECT)
end
