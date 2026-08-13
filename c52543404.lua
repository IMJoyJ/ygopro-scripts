--蕾禍ノ鎧石竜
-- 效果：
-- 这个卡名的①的方法的特殊召唤1回合只能有1次，②的效果1回合只能使用1次。
-- ①：这张卡可以把自己墓地1只昆虫族·植物族·爬虫类族怪兽除外，从手卡特殊召唤。
-- ②：从手卡丢弃1只昆虫族·植物族·爬虫类族怪兽，以昆虫族·植物族·爬虫类族怪兽以外的对方场上1只表侧表示怪兽为对象才能发动。那只怪兽回到手卡。
local s,id,o=GetID()
-- 初始化该卡的效果：注册①的无种类规则特殊召唤（手牌发动，除外墓地1只昆虫·植物·爬虫类族怪兽，1回合1次）和②的起动效果（场上发动，丢弃手卡1只相应种族怪兽，以对方场上非这些种族的表侧表示怪兽为对象弹回手卡，1回合1次），并分别设置条件、代价、目标与处理操作。
function s.initial_effect(c)
	-- 这个卡名的①的方法的特殊召唤1回合只能有1次。①：这张卡可以把自己墓地1只昆虫族·植物族·爬虫类族怪兽除外，从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.spcon)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- 这个卡名的②的效果1回合只能使用1次。②：从手卡丢弃1只昆虫族·植物族·爬虫类族怪兽，以昆虫族·植物族·爬虫类族怪兽以外的对方场上1只表侧表示怪兽为对象才能发动。那只怪兽回到手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"把怪兽弹回手卡"
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetCost(s.thcost)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
-- 特殊召唤代价的过滤条件：该卡必须是昆虫族·植物族·爬虫类族怪兽，且可以作为代价被除外。
function s.spcostfilter1(c)
	return c:IsAbleToRemoveAsCost() and c:IsRace(RACE_INSECT+RACE_PLANT+RACE_REPTILE)
end
-- 特殊召唤规则的条件判断：若c为空表示规则询问则返回true；否则需控制者有可用怪兽区，且墓地存在至少1只满足除外代价条件的怪兽。
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查控制者场上是否有空余的怪兽区域；若没有可用怪兽区则无法进行特殊召唤，返回false。
	if Duel.GetMZoneCount(tp)<=0 then return false end
	-- 获取控制者墓地中所有满足spcostfilter1条件的怪兽，用于判断是否具备可除外的代价。
	local g=Duel.GetMatchingGroup(s.spcostfilter1,tp,LOCATION_GRAVE,0,nil)
	return #g>0
end
-- 实际进行①的特殊召唤处理：从墓地符合条件的怪兽中选择1只，将其表侧表示除外作为特殊召唤的代价。
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	-- 再次获取墓地中所有满足spcostfilter1条件的怪兽，作为本次特殊召唤时可选择的代价集合。
	local g=Duel.GetMatchingGroup(s.spcostfilter1,tp,LOCATION_GRAVE,0,nil)
	-- 向玩家显示选择提示“请选择要除外的卡”，引导玩家从符合条件的墓地怪兽中选取要除外的1张。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local sg=g:Select(tp,1,1,nil)
	if #sg>0 then
		-- 将选择的那张怪兽以表侧表示除外，处理原因为代价（REASON_COST），完成特殊召唤所需的除外动作。
		Duel.Remove(sg,POS_FACEUP,REASON_COST)
	end
end
-- ②效果的丢弃代价过滤条件：该手卡必须是昆虫族·植物族·爬虫类族怪兽，并且可以作为代价被丢弃。
function s.costfilter(c)
	return c:IsRace(RACE_INSECT+RACE_PLANT+RACE_REPTILE) and c:IsDiscardable()
end
-- ②效果发动时的代价处理：合法性检查时确认手卡中存在符合丢弃条件的怪兽；实际发动时从手卡选择并丢弃1张满足条件的怪兽，丢弃原因同时记为代价和丢弃。
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动合法性检查阶段，确认手卡中至少存在1张满足costfilter条件的昆虫族·植物族·爬虫类族怪兽，可以作为丢弃代价。
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 执行丢弃手卡的操作：让玩家从手卡选择1张满足costfilter的怪兽丢弃，丢弃原因包含REASON_COST和REASON_DISCARD。
	Duel.DiscardHand(tp,s.costfilter,1,1,REASON_COST+REASON_DISCARD)
end
-- ②效果选择对象的过滤条件：对象必须是对方场上的表侧表示怪兽，且其种族不属于昆虫族、植物族或爬虫类族。
function s.thfilter(c)
	return not c:IsRace(RACE_INSECT+RACE_PLANT+RACE_REPTILE) and c:IsFaceup()
end
-- ②效果发动时的目标选择与操作信息设置：以对方场上1只表侧表示且非昆虫/植物/爬虫类族的怪兽为对象，选定后将其设为返回手卡的处理对象。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and chkc:IsAbleToHand() end
	-- 在效果发动合法性检查阶段，确认对方场上有至少1只满足thfilter条件的表侧表示怪兽，可以作为此效果的对象。
	if chk==0 then return Duel.IsExistingTarget(s.thfilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 向玩家显示选择提示“请选择要返回手牌的卡”，引导玩家选择符合条件的对方场上怪兽作为效果对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择对方场上1只满足thfilter条件的表侧表示怪兽作为效果对象，并通过SelectTarget将其与当前连锁建立对象联系。
	local g=Duel.SelectTarget(tp,s.thfilter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置本次连锁的操作信息：将选中的对象卡返回手卡（CATEGORY_TOHAND），数量为1，处理者为当前发动者。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- ②效果的实际处理：取回连锁开始时选择的对象卡，若该卡仍与效果关联且是怪兽，则将其送回持有者的手卡。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得②效果发动时选择的那1张对象卡，用于后续判断与返回手卡处理。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsType(TYPE_MONSTER) then
		-- 将仍与效果关联的对象怪兽送入其持有者的手卡，处理原因为效果（REASON_EFFECT），完成“回到手卡”的效果。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
