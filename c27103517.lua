--邪神官チラム・サバク
-- 效果：
-- 「邪神官 契伦·沙巴」的②的效果1回合只能使用1次。
-- ①：自己手卡是5张以上的场合，这张卡可以不用解放作召唤。
-- ②：这张卡被战斗破坏送去墓地时才能发动。这张卡从墓地守备表示特殊召唤。这个效果特殊召唤的这张卡当作调整使用。
function c27103517.initial_effect(c)
	-- ①：自己手卡是5张以上的场合，这张卡可以不用解放作召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(27103517,0))  --"不用解放作召唤"
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetCondition(c27103517.sumcon)
	c:RegisterEffect(e1)
	-- 「邪神官 契伦·沙巴」的②的效果1回合只能使用1次。②：这张卡被战斗破坏送去墓地时才能发动。这张卡从墓地守备表示特殊召唤。这个效果特殊召唤的这张卡当作调整使用。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_DESTROYED)
	e2:SetCountLimit(1,27103517)
	e2:SetCondition(c27103517.spcon)
	e2:SetTarget(c27103517.sptg)
	e2:SetOperation(c27103517.spop)
	c:RegisterEffect(e2)
end
c27103517.treat_itself_tuner=true
-- 定义无解放召唤的规则条件：当c为nil时表示该召唤手续可被采用；实际召唤时要求解放数为0、怪兽等级5以上、己方主要怪兽区有空位，且己方手牌数不少于5张。
function c27103517.sumcon(e,c,minc)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查本次召唤是否无需解放（minc==0），且怪兽等级不低于5，并且己方主要怪兽区存在可用的空格。
	return minc==0 and c:IsLevelAbove(5) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查己方手牌数量是否在5张以上，以满足“自己手卡是5张以上”的①条件。
		and Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)>=5
end
-- ②效果的发动条件：被战斗破坏送去墓地时，确认这张卡当前位于墓地，才允许发动。
function c27103517.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE)
end
-- 效果发动时进行合法性检查：己方主要怪兽区有空位，且这张卡能够以表侧守备表示特殊召唤（满足召唤条件与苏生限制）。
function c27103517.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在检查模式（chk==0）下，先确认己方主要怪兽区存在可用的空格，否则不能发动。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE) end
	-- 设置连锁处理信息：将本次效果登记为特殊召唤这张卡1张，供相关卡片的时点联动判定使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理：若这张卡仍与效果关联，则将其以表侧守备表示特殊召唤；成功后赋予它调整类型，该追加效果不可被无效，并在卡片离场、回手等标准重置时机失效。
function c27103517.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 确认这张卡与效果仍有联系后，将其以表侧守备表示特殊召唤；若特殊召唤成功（返回值非0），则进入赋予调整类型的后续处理。
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP_DEFENSE)~=0 then
		-- 这个效果特殊召唤的这张卡当作调整使用。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_ADD_TYPE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(TYPE_TUNER)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
	end
end
