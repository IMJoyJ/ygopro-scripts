--インフェルニティ・コンジュラー
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：只要自己手卡是0张，对方场上的怪兽的攻击力下降800。
-- ②：这张卡在墓地存在，自己手卡是0张的场合才能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
function c48144778.initial_effect(c)
	-- ①：只要自己手卡是0张，对方场上的怪兽的攻击力下降800。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetValue(-800)
	e1:SetCondition(c48144778.atkcon)
	c:RegisterEffect(e1)
	-- 这个卡名的②的效果1回合只能使用1次。②：这张卡在墓地存在，自己手卡是0张的场合才能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(48144778,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,48144778)
	e2:SetCondition(c48144778.spcon)
	e2:SetTarget(c48144778.sptg)
	e2:SetOperation(c48144778.spop)
	c:RegisterEffect(e2)
end
-- ①效果的发动条件判定：当这张卡的控制者手牌为0张时，①效果适用，对方场上的怪兽攻击力下降800。
function c48144778.atkcon(e)
	-- 检查该效果持有者（自己）手卡数量是否为0，若是则返回true，使①效果适用。
	return Duel.GetFieldGroupCount(e:GetHandlerPlayer(),LOCATION_HAND,0)==0
end
-- ②效果的发动条件判定：自己手卡为0张时才能发动。
function c48144778.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前发动玩家tp的手卡数量是否为0，若是则返回true，满足发动条件。
	return Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)==0
end
-- ②效果发动时的目标处理：检查自己主要怪兽区是否有空位且该卡能否被特殊召唤；满足后设置特殊召唤的操作信息。
function c48144778.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动前检查（chk==0）：若自己主要怪兽区有空位，且墓地的这张卡能够被特殊召唤，则返回true，允许发动。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置本次连锁的特殊召唤操作信息：将墓地的这张卡（e:GetHandler()）作为特殊召唤对象，数量为1，玩家为0（不指定），便于后续处理及应对。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ②效果处理：若这张卡仍与效果相关，则将其表侧攻击表示特殊召唤；召唤成功后，给它附加一个离场时改为除外区的效果。
function c48144778.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断这张卡是否仍与效果相关（未被无效或移动），且特殊召唤成功（返回不为0）时，才继续附加离场除外效果。
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 这个效果特殊召唤的这张卡从场上离开的场合除外。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1,true)
	end
end
