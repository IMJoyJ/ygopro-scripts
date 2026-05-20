--プルーフ・プルフラス
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：特殊召唤的怪兽不在自己场上存在的场合才能发动。这张卡从手卡特殊召唤。这个效果的发动后，直到回合结束时自己不能把怪兽特殊召唤。
-- ②：这张卡召唤·特殊召唤成功的场合才能发动。把1只怪兽上级召唤。
function c85847157.initial_effect(c)
	-- ①：特殊召唤的怪兽不在自己场上存在的场合才能发动。这张卡从手卡特殊召唤。这个效果的发动后，直到回合结束时自己不能把怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(85847157,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,85847157)
	e1:SetCondition(c85847157.spcon)
	e1:SetTarget(c85847157.sptg)
	e1:SetOperation(c85847157.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡召唤·特殊召唤成功的场合才能发动。把1只怪兽上级召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(85847157,1))
	e2:SetCategory(CATEGORY_SUMMON+CATEGORY_MSET)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCondition(c85847157.sumcon)
	e2:SetTarget(c85847157.sumtg)
	e2:SetOperation(c85847157.sumop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
end
-- 过滤条件：特殊召唤的怪兽
function c85847157.cfilter(c)
	return c:IsSummonType(SUMMON_TYPE_SPECIAL)
end
-- 效果①的发动条件：自己场上不存在特殊召唤的怪兽
function c85847157.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在特殊召唤的怪兽，若不存在则返回true
	return not Duel.IsExistingMatchingCard(c85847157.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 效果①的靶向与发动准备：检查怪兽区域是否有空位，且手卡中的这张卡是否可以特殊召唤
function c85847157.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁处理的操作信息为特殊召唤自身
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果①的效果处理：将这张卡特殊召唤，并适用“直到回合结束时自己不能把怪兽特殊召唤”的限制
function c85847157.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
	-- 这个效果的发动后，直到回合结束时自己不能把怪兽特殊召唤。②：这张卡召唤·特殊召唤成功的场合才能发动。把1只怪兽上级召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	-- 给玩家注册“不能特殊召唤怪兽”的限制效果
	Duel.RegisterEffect(e1,tp)
end
-- 效果②的发动条件：不在伤害步骤
function c85847157.sumcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前的游戏阶段
	local ph=Duel.GetCurrentPhase()
	return ph~=PHASE_DAMAGE and ph~=PHASE_DAMAGE_CAL
end
-- 过滤条件：手牌中可以进行上级召唤（通常召唤或盖放）的怪兽
function c85847157.sumfilter(c)
	return c:IsSummonable(true,nil,1) or c:IsMSetable(true,nil,1)
end
-- 效果②的靶向与发动准备：检查手牌中是否存在可以上级召唤的怪兽，并设置召唤的操作信息
function c85847157.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手牌中是否存在至少1只可以进行上级召唤的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c85847157.sumfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 设置连锁处理的操作信息为召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,1,0,0)
end
-- 效果②的效果处理：让玩家从手牌选择1只怪兽进行上级召唤（表侧表示召唤或里侧表示盖放）
function c85847157.sumop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)  --"请选择要召唤的卡"
	-- 让玩家从手牌选择1只满足上级召唤条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c85847157.sumfilter,tp,LOCATION_HAND,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		local s1=tc:IsSummonable(true,nil,1)
		local s2=tc:IsMSetable(true,nil,1)
		-- 如果该怪兽既可表侧召唤也可里侧盖放，则让玩家选择表示形式；若只能表侧召唤，则直接判定为表侧表示
		if (s1 and s2 and Duel.SelectPosition(tp,tc,POS_FACEUP_ATTACK+POS_FACEDOWN_DEFENSE)==POS_FACEUP_ATTACK) or not s2 then
			-- 将选中的怪兽以表侧表示进行上级召唤（需要1个祭品，且无视每回合通常召唤次数限制）
			Duel.Summon(tp,tc,true,nil,1)
		else
			-- 将选中的怪兽以里侧守备表示进行上级盖放（需要1个祭品，且无视每回合通常召唤次数限制）
			Duel.MSet(tp,tc,true,nil,1)
		end
	end
end
