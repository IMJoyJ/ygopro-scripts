--アーマード・サイキッカー
-- 效果：
-- 自己场上有念动力族怪兽表侧表示存在的场合，这张卡可以不用解放作召唤。这张卡战斗破坏对方怪兽的场合，自己受到破坏怪兽的攻击力一半数值的伤害。并且可以再把持有受到的伤害数值以下的攻击力的1只怪兽从自己墓地特殊召唤。
function c62742651.initial_effect(c)
	-- 自己场上有念动力族怪兽表侧表示存在的场合，这张卡可以不用解放作召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(62742651,0))  --"不用解放召唤"
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SUMMON_PROC)
	e1:SetCondition(c62742651.ntcon)
	c:RegisterEffect(e1)
	-- 这张卡战斗破坏对方怪兽的场合，自己受到破坏怪兽的攻击力一半数值的伤害。并且可以再把持有受到的伤害数值以下的攻击力的1只怪兽从自己墓地特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(62742651,1))  --"伤害"
	e2:SetCategory(CATEGORY_DAMAGE+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_BATTLE_DESTROYING)
	e2:SetCondition(c62742651.damcon)
	e2:SetTarget(c62742651.damtg)
	e2:SetOperation(c62742651.damop)
	c:RegisterEffect(e2)
end
-- 过滤自己场上表侧表示的念动力族怪兽
function c62742651.ntfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_PSYCHO)
end
-- 不用解放作召唤的条件函数
function c62742651.ntcon(e,c,minc)
	if c==nil then return true end
	-- 检查是否不需要解放、自身等级是否在5星以上，以及自己场上是否有可用的怪兽区域
	return minc==0 and c:IsLevelAbove(5) and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
		-- 检查自己场上是否存在表侧表示的念动力族怪兽
		and Duel.IsExistingMatchingCard(c62742651.ntfilter,c:GetControler(),LOCATION_MZONE,0,1,nil)
end
-- 战斗破坏对方怪兽时效果的发动条件：此卡在战斗中且被破坏的卡是怪兽
function c62742651.damcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsRelateToBattle() and c:GetBattleTarget():IsType(TYPE_MONSTER)
end
-- 效果发动的准备：计算被破坏怪兽攻击力一半的数值并注册为伤害参数，设置伤害操作信息
function c62742651.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local bc=e:GetHandler():GetBattleTarget()
	local dam=math.floor(bc:GetAttack()/2)
	if dam<0 then dam=0 end
	-- 将计算出的伤害数值保存为当前连锁的参数
	Duel.SetTargetParam(dam)
	-- 设置当前连锁的操作信息为给与玩家伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,tp,dam)
end
-- 过滤墓地中攻击力在受到的伤害数值以下且可以特殊召唤的怪兽
function c62742651.spfilter(c,e,tp,atk)
	return c:IsAttackBelow(atk) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果处理：自己受到伤害，并可以从墓地特殊召唤1只攻击力在伤害数值以下的怪兽
function c62742651.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果发动时保存的伤害数值参数
	local dam=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
	-- 给与自己伤害，并检查是否成功受到伤害以及自己场上是否有空位
	if Duel.Damage(tp,dam,REASON_EFFECT)~=0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 获取自己墓地中满足特殊召唤条件且不受「王家长眠之谷」影响的怪兽
		local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(c62742651.spfilter),tp,LOCATION_GRAVE,0,nil,e,tp,dam)
		-- 若存在可特殊召唤的怪兽，则询问玩家是否进行特殊召唤
		if g:GetCount()~=0 and Duel.SelectYesNo(tp,aux.Stringid(62742651,2)) then  --"是否要特殊召唤？"
			-- 中断当前效果，使后续的特殊召唤与受到的伤害不视为同时处理
			Duel.BreakEffect()
			-- 提示玩家选择要特殊召唤的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			local sg=g:Select(tp,1,1,nil)
			-- 将选中的怪兽以表侧表示特殊召唤到自己场上
			Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
