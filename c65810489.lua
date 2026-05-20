--黄金の邪神像
-- 效果：
-- 盖放的这张卡被破坏送去墓地时，在自己场上把1只「邪神衍生物」（恶魔族·暗·4星·攻/守1000）特殊召唤。
function c65810489.initial_effect(c)
	-- 盖放的这张卡被破坏送去墓地时，在自己场上把1只「邪神衍生物」（恶魔族·暗·4星·攻/守1000）特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(65810489,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCondition(c65810489.spcon)
	e1:SetTarget(c65810489.sptg)
	e1:SetOperation(c65810489.spop)
	c:RegisterEffect(e1)
end
-- 检查此卡是否在场上盖放（背面表示）的状态下被破坏并送去墓地
function c65810489.spcon(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,REASON_DESTROY)~=0
		and e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
		and e:GetHandler():IsPreviousPosition(POS_FACEDOWN)
end
-- 效果发动的目标检查与操作信息设置，由于是必发效果，直接返回true并设置产生衍生物和特殊召唤的操作信息
function c65810489.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置当前连锁的操作信息为：产生1只衍生物
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	-- 设置当前连锁的操作信息为：特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
-- 效果处理的执行函数，在自己场上特殊召唤1只「邪神衍生物」
function c65810489.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上的主要怪兽区域是否有空位，若无则结束效果处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<1 then return end
	-- 检查玩家是否可以特殊召唤指定数值（恶魔族·暗·4星·攻/守1000）的「邪神衍生物」
	if not Duel.IsPlayerCanSpecialSummonMonster(tp,65810490,0,TYPES_TOKEN_MONSTER,1000,1000,4,RACE_FIEND,ATTRIBUTE_DARK) then return end
	-- 创建卡号为65810490的「邪神衍生物」卡片
	local token=Duel.CreateToken(tp,65810490)
	-- 将该衍生物以表侧表示特殊召唤到自己的场上
	Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)
end
