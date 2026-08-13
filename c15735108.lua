--マジックカード「クロス・ソウル」
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：进行1只怪兽的上级召唤。那个时候，也能作为自己场上的怪兽的代替而把对方场上的怪兽解放。这个效果上级召唤的怪兽在这个回合不能解放。
-- ②：这张卡从场上送去墓地的场合发动。对方可以让这张卡的①的效果适用。
local s,id,o=GetID()
-- 创建并注册这张卡的两个效果：e1为①效果的魔法卡发动（可进行上级召唤并使对方怪兽可作为祭品），e2为②效果（这张卡从场上送去墓地时发动，对方可选择让①效果适用）。
function s.initial_effect(c)
	-- 对应①效果及卡名1回合1次限制：这个卡名的卡在1回合只能发动1张。①：进行1只怪兽的上级召唤。那个时候，也能作为自己场上的怪兽的代替而把对方场上的怪兽解放。这个效果上级召唤的怪兽在这个回合不能解放。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SUMMON+CATEGORY_MSET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.sumtg)
	e1:SetOperation(s.sumop)
	c:RegisterEffect(e1)
	-- 对应②效果：②：这张卡从场上送去墓地的场合发动。对方可以让这张卡的①的效果适用。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCondition(s.sumcon2)
	e2:SetTarget(s.sumtg2)
	e2:SetOperation(s.sumop2)
	c:RegisterEffect(e2)
end
-- 筛选函数：给手牌中的候选怪兽临时附加“可用对方场上表侧攻击/里侧守备怪兽作为追加祭品”的效果，然后检查该怪兽是否能用至少1只祭品进行上级召唤（或里侧覆盖），若可以则返回true，最后重置临时效果。
function s.sumfilter(c,ec)
	-- 也能作为自己场上的怪兽的代替而把对方场上的怪兽解放。
	local e1=Effect.CreateEffect(ec)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_ADD_EXTRA_TRIBUTE)
	e1:SetRange(LOCATION_HAND)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetValue(POS_FACEUP_ATTACK+POS_FACEDOWN_DEFENSE)
	c:RegisterEffect(e1)
	local res=c:IsSummonable(true,nil,1) or c:IsMSetable(true,nil,1)
	e1:Reset()
	return res
end
-- 发动效果的目标判定函数：在发动时确认手牌中存在至少1只能够进行上级召唤的怪兽（满足s.sumfilter），满足则允许发动；随后设置操作信息，声明将进行召唤。
function s.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手牌中是否存在至少1只满足s.sumfilter的怪兽（即能够使用对方怪兽作为祭品进行上级召唤的怪兽），作为效果发动条件。
	if chk==0 then return Duel.IsExistingMatchingCard(s.sumfilter,tp,LOCATION_HAND,0,1,nil,e:GetHandler()) end
	-- 设置本次连锁的操作信息，声明效果处理将进行1只怪兽的召唤（CATEGORY_SUMMON）。
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,1,0,0)
end
-- 效果发动后的处理函数：提示玩家选择要召唤的怪兽，从手牌中选出1只满足s.sumfilter的怪兽，选到则调用s.summon实际执行上级召唤并附加不能解放的效果。
function s.sumop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 向玩家发送“请选择要召唤的卡”的选择提示信息，用于选择召唤怪兽的界面显示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)  --"请选择要召唤的卡"
	-- 让玩家tp从手牌中选择1只满足s.sumfilter条件的怪兽（排除魔法卡自身），并返回选中的第一张卡。
	local tc=Duel.SelectMatchingCard(tp,s.sumfilter,tp,LOCATION_HAND,0,1,1,nil,c):GetFirst()
	if tc then s.summon(e,tp,tc) end
end
-- 实际执行上级召唤的函数：先为选中的怪兽赋予“可将对方场上表侧攻击/里侧守备怪兽作为追加祭品”的持续效果；然后根据玩家选择的表示形式，用至少1只祭品进行表侧攻击表示通常召唤或里侧守备表示设置；召唤/设置成功后，给该怪兽附加“这个回合不能解放”的效果（同时限制其不能作为上级召唤或其它效果的解放祭品）。
function s.summon(e,tp,tc)
	local c=e:GetHandler()
	-- 也能作为自己场上的怪兽的代替而把对方场上的怪兽解放。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_ADD_EXTRA_TRIBUTE)
	e1:SetRange(LOCATION_HAND)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetValue(POS_FACEUP_ATTACK+POS_FACEDOWN_DEFENSE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	tc:RegisterEffect(e1)
	local s1=tc:IsSummonable(true,nil,1)
	local s2=tc:IsMSetable(true,nil,1)
	-- 判断召唤表示形式：若该怪兽既能表侧攻击表示上级召唤也能里侧守备表示设置，则让玩家选择表侧攻击还是里侧守备；若玩家选择表侧攻击，或者该怪兽不能里侧设置，则按表侧攻击表示召唤。
	if (s1 and s2 and Duel.SelectPosition(tp,tc,POS_FACEUP_ATTACK+POS_FACEDOWN_DEFENSE)==POS_FACEUP_ATTACK) or not s2 then
		-- 以表侧攻击表示对tc进行通常召唤（上级召唤），忽略通常召唤次数限制，至少解放1只祭品。
		Duel.Summon(tp,tc,true,nil,1)
	else
		-- 以里侧守备表示对tc进行通常召唤的覆盖（Set），忽略通常召唤次数限制，至少解放1只祭品。
		Duel.MSet(tp,tc,true,nil,1)
	end
	-- 对应“这个效果上级召唤的怪兽在这个回合不能解放”以及②效果：这个效果上级召唤的怪兽在这个回合不能解放。②：这张卡从场上送去墓地的场合发动。对方可以让这张卡的①的效果适用。具体包括：给上级召唤成功的怪兽附加不能作为上级召唤祭品/不能作为其他解放的效果；以及这张卡从场上送去墓地时，若对方手牌中存在可召唤的怪兽且对方选择适用，则对方也可进行相同的上级召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_UNRELEASABLE_SUM)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD+RESET_PHASE+PHASE_END)
	e2:SetValue(1)
	tc:RegisterEffect(e2,true)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UNRELEASABLE_NONSUM)
	tc:RegisterEffect(e3,true)
end
-- ②效果的触发条件：这张卡从场上（LOCATION_ONFIELD）被送去墓地时满足条件，即e:GetHandler()的先前位置为场上。
function s.sumcon2(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- ②效果的目标判定函数：发动时不需要额外检查条件（chk==0直接返回true），并设置操作信息为召唤，以便在效果处理时进行召唤相关操作。
function s.sumtg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息，声明本连锁的处理中包含1只怪兽的召唤（CATEGORY_SUMMON）。
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,1,0,0)
end
-- ②效果的处理函数：若对方手牌存在可进行该上级召唤的怪兽，则询问对方是否适用这张卡的①效果；若对方选择是，则由对方选择手牌中的1只怪兽，并调用s.summon以该效果进行上级召唤。
function s.sumop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断对方（1-tp）是否有手牌怪兽可适用①效果，并在有可选怪兽时询问对方“是否使用「魔法卡「灵魂交错」」的效果？”；只有对方选择“是”时才继续处理。
	if Duel.IsExistingMatchingCard(s.sumfilter,1-tp,LOCATION_HAND,0,1,nil,c) and Duel.SelectYesNo(1-tp,aux.Stringid(id,2)) then  --"是否使用「魔法卡「灵魂交错」」的效果？"
		-- 向对方玩家发送“请选择要召唤的卡”的选择提示。
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_SUMMON)  --"请选择要召唤的卡"
		-- 让对方玩家从手牌中选择1只满足s.sumfilter条件的怪兽，并取得选中的第一张卡。
		local tc=Duel.SelectMatchingCard(1-tp,s.sumfilter,1-tp,LOCATION_HAND,0,1,1,nil,c):GetFirst()
		s.summon(e,1-tp,tc)
	end
end
