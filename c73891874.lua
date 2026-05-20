--ホワイト・ホーンズ・ドラゴン
-- 效果：
-- ①：这张卡召唤·特殊召唤成功的场合，以对方墓地最多5张魔法卡为对象发动。那些卡除外，这张卡的攻击力上升那些除外的卡数量×300。
function c73891874.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤成功的场合，以对方墓地最多5张魔法卡为对象发动。那些卡除外，这张卡的攻击力上升那些除外的卡数量×300。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(73891874,0))  --"除外"
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c73891874.target)
	e1:SetOperation(c73891874.operation)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
end
-- 过滤对方墓地中可以被除外的魔法卡
function c73891874.filter(c)
	return c:IsType(TYPE_SPELL) and c:IsAbleToRemove()
end
-- 效果①的发动准备与目标选择，确认对方墓地存在可除外的魔法卡，并让玩家选择1到5张作为对象
function c73891874.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(1-tp) and c73891874.filter(chkc) end
	if chk==0 then return true end
	-- 提示玩家选择要除外的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择对方墓地1到5张符合条件的魔法卡作为效果对象
	local g=Duel.SelectTarget(tp,c73891874.filter,tp,0,LOCATION_GRAVE,1,5,nil)
	-- 设置效果处理信息，表明该效果包含除外对方墓地中被选择卡片的操作
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,g:GetCount(),1-tp,LOCATION_GRAVE)
end
-- 效果①的处理，将作为对象的卡片除外，并根据实际除外的卡片数量提升这张卡的攻击力
function c73891874.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中仍与该效果相关的对象卡片
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	-- 将这些卡片表侧表示除外，并获取实际被除外的卡片数量
	local ct=Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
	local c=e:GetHandler()
	if ct>0 and c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 这张卡的攻击力上升那些除外的卡数量×300。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		e1:SetValue(ct*300)
		c:RegisterEffect(e1)
	end
end
