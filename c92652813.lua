--憑依覚醒－大稲荷火
-- 效果：
-- 这个卡名的②③的效果1回合各能使用1次。
-- ①：这张卡可以把自己场上的表侧表示的1只魔法师族怪兽和1只4星以下的炎属性怪兽送去墓地，从手卡·卡组特殊召唤。
-- ②：这张卡的①的方法特殊召唤时才能发动。给与对方为对方场上1只怪兽的原本攻击力数值的伤害。
-- ③：这张卡从场上送去墓地的场合才能发动。从卡组把1张「火灵术」卡或「凭依」魔法·陷阱卡加入手卡。
function c92652813.initial_effect(c)
	-- ①：这张卡可以把自己场上的表侧表示的1只魔法师族怪兽和1只4星以下的炎属性怪兽送去墓地，从手卡·卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND+LOCATION_DECK)
	e1:SetCondition(c92652813.spcon)
	e1:SetTarget(c92652813.sptg)
	e1:SetOperation(c92652813.spop)
	e1:SetValue(SUMMON_VALUE_SELF)
	c:RegisterEffect(e1)
	-- ②：这张卡的①的方法特殊召唤时才能发动。给与对方为对方场上1只怪兽的原本攻击力数值的伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(92652813,0))
	e2:SetCategory(CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCountLimit(1,92652813)
	e2:SetCondition(c92652813.condition)
	e2:SetTarget(c92652813.dmtg)
	e2:SetOperation(c92652813.dmop)
	c:RegisterEffect(e2)
	-- ③：这张卡从场上送去墓地的场合才能发动。从卡组把1张「火灵术」卡或「凭依」魔法·陷阱卡加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(92652813,1))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCountLimit(1,92652814)
	e3:SetCondition(c92652813.thcon)
	e3:SetTarget(c92652813.thtg)
	e3:SetOperation(c92652813.thop)
	c:RegisterEffect(e3)
end
-- 过滤场上表侧表示且可以送去墓地的卡片
function c92652813.spfilter(c)
	return c:IsFaceup() and c:IsAbleToGraveAsCost()
end
-- 过滤4星以下的炎属性怪兽
function c92652813.spfilter2(c)
	return c:IsAttribute(ATTRIBUTE_FIRE) and c:IsLevelBelow(4)
end
-- 检查选取的卡片组是否满足怪兽区域空位要求，且包含1只魔法师族怪兽和1只4星以下炎属性怪兽
function c92652813.fselect(g,tp)
	-- 检查怪兽区空位，并验证卡片组是否由1只魔法师族怪兽和1只满足spfilter2过滤条件的怪兽组成
	return aux.mzctcheck(g,tp) and aux.gffcheck(g,Card.IsRace,RACE_SPELLCASTER,c92652813.spfilter2,nil)
end
-- 特殊召唤规则的条件判定函数
function c92652813.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取自己场上所有表侧表示且可以送去墓地的怪兽
	local g=Duel.GetMatchingGroup(c92652813.spfilter,tp,LOCATION_MZONE,0,nil)
	return g:CheckSubGroup(c92652813.fselect,2,2,tp)
end
-- 特殊召唤规则的释放怪兽选择（Target）函数
function c92652813.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取自己场上所有表侧表示且可以送去墓地的怪兽
	local g=Duel.GetMatchingGroup(c92652813.spfilter,tp,LOCATION_MZONE,0,nil)
	-- 提示玩家选择要送去墓地的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	local sg=g:SelectSubGroup(tp,c92652813.fselect,true,2,2,tp)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 特殊召唤规则的执行（Operation）函数
function c92652813.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将选定的怪兽作为特殊召唤的消耗送去墓地
	Duel.SendtoGrave(g,REASON_SPSUMMON)
	g:DeleteGroup()
end
-- 判定此卡是否通过自身①的方法特殊召唤成功
function c92652813.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetSummonType()==SUMMON_TYPE_SPECIAL+SUMMON_VALUE_SELF
end
-- 过滤对方场上表侧表示且原本攻击力大于0的怪兽
function c92652813.dmfilter(c)
	return c:IsFaceup() and c:GetBaseAttack()>0
end
-- 伤害效果的发动准备与合法性检测（Target）
function c92652813.dmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方场上是否存在至少1只满足条件的表侧表示怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c92652813.dmfilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 设置效果处理信息为给与对方玩家伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,0)
end
-- 伤害效果的执行（Operation）
function c92652813.dmop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择对方场上的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPPO)  --"请选择对方的卡"
	-- 让玩家选择对方场上1只满足条件的表侧表示怪兽
	local g=Duel.SelectMatchingCard(tp,c92652813.dmfilter,tp,0,LOCATION_MZONE,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		-- 选中怪兽时在场上显示绿框特效
		Duel.HintSelection(g)
		-- 给与对方该怪兽原本攻击力数值的伤害
		Duel.Damage(1-tp,tc:GetBaseAttack(),REASON_EFFECT)
	end
end
-- 判定此卡是否从场上送去墓地
function c92652813.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 过滤卡组中可以加入手牌的「火灵术」卡片或「凭依」魔法·陷阱卡
function c92652813.thfilter(c)
	return ((c:IsSetCard(0xc0) and c:IsType(TYPE_SPELL+TYPE_TRAP)) or c:IsSetCard(0x614c)) and c:IsAbleToHand()
end
-- 检索效果的发动准备与合法性检测（Target）
function c92652813.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1张满足条件的卡片
	if chk==0 then return Duel.IsExistingMatchingCard(c92652813.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置效果处理信息为从卡组将1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 检索效果的执行（Operation）
function c92652813.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1张满足条件的卡片
	local g=Duel.SelectMatchingCard(tp,c92652813.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选取的卡片加入玩家手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示加入手牌的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
