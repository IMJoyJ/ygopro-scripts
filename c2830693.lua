--虹クリボー
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：对方怪兽的攻击宣言时，以那1只攻击怪兽为对象才能发动。这张卡从手卡当作装备卡使用给那只怪兽装备。装备怪兽不能攻击。
-- ②：这张卡在墓地存在的场合，对方怪兽的直接攻击宣言时才能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
function c2830693.initial_effect(c)
	-- ①：对方怪兽的攻击宣言时，以那1只攻击怪兽为对象才能发动。这张卡从手卡当作装备卡使用给那只怪兽装备。装备怪兽不能攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(2830693,0))  --"装备"
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,2830693)
	e1:SetTarget(c2830693.eqtg)
	e1:SetOperation(c2830693.eqop)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在的场合，对方怪兽的直接攻击宣言时才能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(2830693,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,2830694)
	e2:SetCondition(c2830693.spcon)
	e2:SetTarget(c2830693.sptg)
	e2:SetOperation(c2830693.spop)
	c:RegisterEffect(e2)
end
-- 效果①的发动时点与指定对象处理：获取攻击宣言的怪兽，确认自己魔陷区有空位、攻击怪兽为对方怪兽且与战斗相关并能成为效果对象，然后将该怪兽设为对象。
function c2830693.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 取得本次攻击宣言的攻击怪兽。
	local at=Duel.GetAttacker()
	if chkc then return chkc==at end
	-- 发动条件检查：自己魔法与陷阱区域必须存在空位，才能将手牌的这张卡装备出去。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and at:IsControler(1-tp) and at:IsRelateToBattle() and at:IsCanBeEffectTarget(e) end
	-- 将攻击怪兽设置为效果①的对象。
	Duel.SetTargetCard(at)
end
-- 效果①处理：若这张卡仍与效果关联、魔陷区有空位且对象怪兽仍表侧表示并与效果关联，则将这张卡装备给对象怪兽，并给该怪兽附加不能攻击的效果；否则这张卡送去墓地。
function c2830693.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取出效果①发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if not c:IsRelateToEffect(e) then return end
	-- 处理时再次确认魔陷区是否有空位、对象怪兽是否为表侧表示且仍与效果关联，若条件不满足则装备处理失败。
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 or tc:IsFacedown() or not tc:IsRelateToEffect(e) then
		-- 因条件不满足导致无法装备时，将这张卡从手牌送去墓地。
		Duel.SendtoGrave(c,REASON_EFFECT)
	else
		-- 将这张卡作为装备魔法卡装备给对象怪兽。
		Duel.Equip(tp,c,tc)
		-- 给那只怪兽装备。
		local e1=Effect.CreateEffect(tc)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(c2830693.eqlimit)
		c:RegisterEffect(e1)
		-- 装备怪兽不能攻击。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_EQUIP)
		e2:SetCode(EFFECT_CANNOT_ATTACK)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e2)
	end
end
-- 装备限制判定：只有该效果的所有者（即最初选择的那只攻击怪兽）才能装备这张卡。
function c2830693.eqlimit(e,c)
	return e:GetOwner()==c
end
-- 效果②的发动条件：对方怪兽进行直接攻击宣言时才能发动，即攻击怪兽为对方控制且攻击目标为玩家自身。
function c2830693.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定攻击怪兽是对方怪兽且攻击目标为空（直接攻击）。
	return Duel.GetAttacker():IsControler(1-tp) and Duel.GetAttackTarget()==nil
end
-- 效果②发动时确认：自己主要怪兽区有空位，且这张卡能够特殊召唤；满足则发动并登记特殊召唤操作信息。
function c2830693.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：自己主要怪兽区存在空位，用于特殊召唤这张卡。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置本连锁的操作信息：效果处理时将这张卡特殊召唤（分类为特殊召唤）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果②处理：若这张卡仍与效果关联，则将其表侧攻击表示特殊召唤，成功后给这张卡附加“从场上离开时除外”的效果。
function c2830693.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 确认这张卡仍与效果关联后将其特殊召唤到自己的主要怪兽区，并判断是否特殊召唤成功。
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- 这个效果特殊召唤的这张卡从场上离开的场合除外。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1,true)
	end
end
