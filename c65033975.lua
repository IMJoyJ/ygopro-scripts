--アザミナの妖魔
-- 效果：
-- 这个卡名在规则上也当作「罪宝」卡使用。这个卡名的①②的效果1回合各能使用1次。
-- ①：自己的手卡·场上的这张卡被自己或对方发动的效果所送去墓地的场合或者所除外的场合才能发动。这张卡特殊召唤。
-- ②：自己的「蓟花」怪兽或「白森林」怪兽战斗破坏对方怪兽时，以自己墓地1张「罪宝」魔法·陷阱卡为对象才能发动。那张卡加入手卡。
local s,id,o=GetID()
-- 初始化效果：注册①效果（手卡·场上的这张卡被效果送墓/除外时特召）和②效果（自己的「蓟花」或「白森林」怪兽战破对方怪兽时回收墓地「罪宝」魔陷）。
function s.initial_effect(c)
	-- ①：自己的手卡·场上的这张卡被自己或对方发动的效果所送去墓地的场合或者所除外的场合才能发动。这张卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_REMOVE)
	c:RegisterEffect(e2)
	-- ②：自己的「蓟花」怪兽或「白森林」怪兽战斗破坏对方怪兽时，以自己墓地1张「罪宝」魔法·陷阱卡为对象才能发动。那张卡加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"魔陷回手"
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_BATTLE_DESTROYING)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id+o)
	e3:SetCondition(s.thcon)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
end
-- 判定①效果的发动条件：这张卡原本在自己的手卡或场上，且因对方或自己发动的效果而被送去墓地或除外。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_HAND+LOCATION_ONFIELD) and e:GetHandler():IsPreviousControler(tp)
		and re and re:IsActivated() and r&REASON_EFFECT~=0
end
-- ①效果的发动准备：检查自身是否能特殊召唤，并设置特殊召唤的操作信息。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查自己场上的怪兽区域是否有空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤的操作信息，准备将自身特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- ①效果的效果处理：若自身仍与效果相关，则将自身特殊召唤。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将自身以表侧表示特殊召唤到自己的场上。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 判定②效果的发动条件：自己场上表侧表示的「蓟花」或「白森林」怪兽战斗破坏了对方怪兽。
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	local rc=eg:GetFirst()
	return rc:IsRelateToBattle() and rc:IsStatus(STATUS_OPPO_BATTLE) and rc:IsControler(tp)
		and rc:IsLocation(LOCATION_MZONE) and rc:IsFaceup() and rc:IsSetCard(0x1bc,0x1b1)
end
-- 过滤条件：墓地的「罪宝」魔法·陷阱卡且能加入手卡。
function s.thfilter(c)
	return c:IsSetCard(0x19e) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- ②效果的发动准备：选择自己墓地1张满足条件的「罪宝」魔陷卡作为对象，并设置加入手卡的操作信息。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.thfilter(chkc) end
	-- 检查自己墓地是否存在可以成为效果对象的「罪宝」魔法·陷阱卡。
	if chk==0 then return Duel.IsExistingTarget(s.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 给发动效果的玩家提示“请选择要加入手牌的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 玩家选择墓地1张满足条件的「罪宝」魔陷卡作为效果对象。
	local g=Duel.SelectTarget(tp,s.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置加入手卡的操作信息，准备将选中的卡加入手卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- ②效果的效果处理：将作为对象的卡加入手卡。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中作为效果对象的卡片。
	local tc=Duel.GetFirstTarget()
	-- 检查对象卡是否仍与效果相关，且不受「王家之谷」等卡片效果的影响。
	if tc:IsRelateToEffect(e) and aux.NecroValleyFilter()(tc) then
		-- 将对象卡片因效果加入持有者的手卡。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
