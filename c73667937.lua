--WW－ダイヤモンド・ベル
-- 效果：
-- 调整＋调整以外的风属性怪兽1只以上
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡同调召唤成功的场合，以自己墓地1只「风魔女」怪兽为对象才能发动。给与对方那只怪兽的攻击力一半数值的伤害。
-- ②：1回合1次，对方因战斗·效果受到伤害的场合，以场上1张卡为对象才能发动。那张卡破坏。这张卡是已只用「风魔女」怪兽为素材作同调召唤的场合，这个效果1回合可以使用最多2次。
function c73667937.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加同调召唤手续：调整＋调整以外的风属性怪兽1只以上
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(Card.IsAttribute,ATTRIBUTE_WIND),1)
	-- ①：这张卡同调召唤成功的场合，以自己墓地1只「风魔女」怪兽为对象才能发动。给与对方那只怪兽的攻击力一半数值的伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(73667937,0))  --"伤害"
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,73667937)
	e1:SetCondition(c73667937.damcon)
	e1:SetTarget(c73667937.damtg)
	e1:SetOperation(c73667937.damop)
	c:RegisterEffect(e1)
	-- ②：1回合1次，对方因战斗·效果受到伤害的场合，以场上1张卡为对象才能发动。那张卡破坏。这张卡是已只用「风魔女」怪兽为素材作同调召唤的场合，这个效果1回合可以使用最多2次。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(73667937,1))  --"破坏"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_DAMAGE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c73667937.descon)
	e2:SetTarget(c73667937.destg)
	e2:SetOperation(c73667937.desop)
	c:RegisterEffect(e2)
	-- 这张卡是已只用「风魔女」怪兽为素材作同调召唤的场合
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetCondition(c73667937.matcon)
	e3:SetOperation(c73667937.matop)
	c:RegisterEffect(e3)
	-- 这张卡是已只用「风魔女」怪兽为素材作同调召唤的场合
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_MATERIAL_CHECK)
	e4:SetValue(c73667937.valcheck)
	e4:SetLabelObject(e3)
	c:RegisterEffect(e4)
end
-- 判定此卡是否同调召唤成功
function c73667937.damcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 过滤自己墓地中攻击力在1以上的「风魔女」怪兽
function c73667937.damfilter(c)
	return c:IsSetCard(0xf0) and c:IsAttackAbove(1)
end
-- 效果①（伤害效果）的发动准备：检查并选择自己墓地1只「风魔女」怪兽作为对象，并设置给与对方伤害的操作信息
function c73667937.damtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c73667937.damfilter(chkc) end
	-- 检查自己墓地是否存在符合条件的「风魔女」怪兽
	if chk==0 then return Duel.IsExistingTarget(c73667937.damfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择自己墓地1只符合条件的「风魔女」怪兽作为对象
	local g=Duel.SelectTarget(tp,c73667937.damfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置给与对方该怪兽攻击力一半数值伤害的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,math.floor(g:GetFirst():GetAttack()/2))
end
-- 效果①（伤害效果）的处理：给与对方作为对象的怪兽攻击力一半数值的伤害
function c73667937.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 给与对方该怪兽攻击力一半数值的效果伤害
		Duel.Damage(1-tp,math.floor(tc:GetAttack()/2),REASON_EFFECT)
	end
end
-- 判定是否为对方因战斗或效果受到伤害的场合
function c73667937.descon(e,tp,eg,ep,ev,re,r,rp)
	return ep==1-tp and bit.band(r,REASON_BATTLE+REASON_EFFECT)~=0
end
-- 效果②（破坏效果）的发动准备：根据素材情况判定发动次数限制，并选择场上1张卡作为对象，设置破坏的操作信息
function c73667937.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsOnField() end
	if chk==0 then
		local b
		if c:GetFlagEffect(73667937)>0 then
			b=c:GetFlagEffect(73667938)<2
		else
			b=c:GetFlagEffect(73667938)<1
		end
		-- 检查本回合发动次数是否未达上限，且场上是否存在可以作为对象的卡
		return b and Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
	end
	c:RegisterFlagEffect(73667938,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上1张卡作为对象
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置破坏该卡的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果②（破坏效果）的处理：破坏作为对象的卡
function c73667937.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 破坏作为对象的卡
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- 判定此卡是否同调召唤成功，且同调素材是否仅为「风魔女」怪兽
function c73667937.matcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO) and e:GetLabel()==1
end
-- 给此卡注册一个标记，表示其是用「风魔女」怪兽为素材作同调召唤的
function c73667937.matop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(73667937,RESET_EVENT+RESETS_STANDARD,0,1)
end
-- 过滤非「风魔女」怪兽的卡
function c73667937.mfilter(c)
	return not c:IsSetCard(0xf0)
end
-- 检查同调素材，若全部为「风魔女」怪兽，则将标签值设为1，否则设为0
function c73667937.valcheck(e,c)
	local g=c:GetMaterial()
	if #g>0 and not g:IsExists(c73667937.mfilter,1,nil) then
		e:GetLabelObject():SetLabel(1)
	else
		e:GetLabelObject():SetLabel(0)
	end
end
