--灯魚
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡作为同调素材送去墓地的场合才能发动。在自己场上把2只「灯衍生物」（鱼族·炎·2星·攻/守0）特殊召唤。这个回合，自己不是鱼族怪兽不能从额外卡组特殊召唤。
-- ②：自己场上有鱼族同调怪兽存在的场合，把墓地的这张卡除外，以场上1张卡为对象才能发动。那张卡破坏。
local s,id,o=GetID()
-- 初始化灯鱼的效果：添加同调召唤手续（调整＋调整以外的怪兽1只以上）、苏生限制，并注册①（作为同调素材送去墓地时特招衍生物并附加自肃）和②（有鱼族同调怪兽时除外自身破坏场上1张卡）两个效果。
function s.initial_effect(c)
	-- 为灯鱼添加同调召唤手续：需要1只调整＋调整以外的怪兽1只以上（这里对调整和非调整的种族/属性没有额外限制）。
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：这张卡作为同调素材送去墓地的场合才能发动。在自己场上把2只「灯衍生物」（鱼族·炎·2星·攻/守0）特殊召唤。这个回合，自己不是鱼族怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤衍生物"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_BE_MATERIAL)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：自己场上有鱼族同调怪兽存在的场合，把墓地的这张卡除外，以场上1张卡为对象才能发动。那张卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.descon)
	-- 设置②效果的发动代价为把墓地的这张卡除外（使用aux.bfgcost）。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
end
-- ①效果的发动条件：这张卡作为同调素材被送去墓地的场合（r==REASON_SYNCHRO）才能发动；此效果是场合型诱发效果，不会错过时点。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and r==REASON_SYNCHRO
end
-- ①效果的发动时点检查：确认自己没有被“禁止同时特殊召唤2只以上怪兽”的效果影响（如青眼精灵龙）、有足够空位、且能够特殊召唤灯衍生物。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 检查自己场上是否存在至少2个可用的主要怪兽区域，用于放置2只衍生物。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		-- 检查自己是否能够特殊召唤灯衍生物（鱼族·炎·2星·攻/守0的衍生物）。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,35834120,0,TYPES_TOKEN_MONSTER,0,0,1,RACE_FISH,ATTRIBUTE_FIRE) end
	-- 设置操作信息：本次效果将特殊召唤2只衍生物（CATEGORY_TOKEN）。
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,2,0,0)
	-- 设置操作信息：本次效果将特殊召唤2只怪兽（CATEGORY_SPECIAL_SUMMON）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,0,0)
end
-- ①效果处理：先给自己附加“这个回合不能从额外卡组特殊召唤鱼族以外怪兽”的自肃，然后在自己场上特殊召唤2只灯衍生物。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 这个卡名的①②的效果1回合各能使用1次。①：这张卡作为同调素材送去墓地的场合才能发动。在自己场上把2只「灯衍生物」（鱼族·炎·2星·攻/守0）特殊召唤。这个回合，自己不是鱼族怪兽不能从额外卡组特殊召唤。②：自己场上有鱼族同调怪兽存在的场合，把墓地的这张卡除外，以场上1张卡为对象才能发动。那张卡破坏。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将刚创建的自肃限制效果注册给当前玩家tp，使其在结束阶段前持续生效。
	Duel.RegisterEffect(e1,tp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 再次确认可用怪兽区数量，若不足2个则中止特殊召唤处理（防止区域变化导致无法特招）。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<2 then return end
	-- 再次确认玩家仍能特殊召唤灯衍生物，若不能则中止处理。
	if not Duel.IsPlayerCanSpecialSummonMonster(tp,35834120,0,TYPES_TOKEN_MONSTER,0,0,1,RACE_FISH,ATTRIBUTE_FIRE) then return end
	for i=1,2 do
		-- 创建1只灯衍生物（卡号35834120）。
		local token=Duel.CreateToken(tp,id+o)
		-- 将衍生物以表侧攻击表示特殊召唤到tp场上（作为连锁处理中的一个步骤，暂未完成）。
		Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
	end
	-- 结束连锁中的特殊召唤步骤，完成所有衍生物的特殊召唤。
	Duel.SpecialSummonComplete()
end
-- 自肃效果的过滤条件：若怪兽不是鱼族且从额外卡组特殊召唤，则禁止该特殊召唤。
function s.splimit(e,c)
	return not c:IsRace(RACE_FISH) and c:IsLocation(LOCATION_EXTRA)
end
-- ②效果的辅助过滤：判断怪兽是否为表侧表示且是鱼族同调怪兽。
function s.cfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_FISH) and c:IsType(TYPE_SYNCHRO)
end
-- ②效果的发动条件：自己场上有表侧表示的鱼族同调怪兽存在。
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在至少1只满足s.cfilter的鱼族同调怪兽。
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- ②效果的目标处理：选择双方场上1张卡作为对象（取对象），并设置破坏操作信息。
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() end
	-- 在效果发动时检查场上是否存在可以成为破坏对象的卡。
	if chk==0 then return Duel.IsExistingTarget(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 弹出选择提示，要求玩家选择要破坏的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家从双方场上选择1张卡，并将其设为当前连锁的②效果对象。
	local g=Duel.SelectTarget(tp,nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置操作信息：本次效果将破坏所选择的对象卡。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- ②效果处理：取得对象卡，若它仍与效果关联则将其破坏。
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 取出当前连锁中选定的对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 以效果原因破坏对象卡。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
