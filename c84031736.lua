--道化の一座『終演』
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：上级召唤的怪兽在自己场上存在的场合，把手卡任意数量丢弃，以那个数量的场上的表侧表示卡为对象才能发动。那些卡破坏。
-- ②：把墓地的这张卡除外，把自己的手卡·场上1只仪式·融合·同调·超量·灵摆·连接怪兽解放才能发动。原本的等级·阶级·连接的数值和那只怪兽不同的1只「道化一座」怪兽从自己的卡组·墓地加入手卡。
local s,id,o=GetID()
-- 初始化卡片效果，注册破坏场上卡片的效果以及墓地除外并解放特定怪兽检索「道化一座」怪兽的效果
function s.initial_effect(c)
	-- ①：上级召唤的怪兽在自己场上存在的场合，把手卡任意数量丢弃，以那个数量的场上的表侧表示卡为对象才能发动。那些卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"破坏效果"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE+TIMING_MAIN_END)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.condition)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外，把自己的手卡·场上1只仪式·融合·同调·超量·灵摆·连接怪兽解放才能发动。原本的等级·阶级·连接的数值和那只怪兽不同的1只「道化一座」怪兽从自己的卡组·墓地加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"检索效果"
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o)
	-- 将自身从墓地表侧表示除外作为效果发动的Cost
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
-- 过滤上级召唤成功的怪兽
function s.cfilter(c)
	return c:IsSummonType(SUMMON_TYPE_ADVANCE)
end
-- 定义效果①的发动条件函数
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 确认自己场上是否存在上级召唤成功的怪兽
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 定义效果①发动时的Cost花费函数，计算破坏上限并丢弃对应数量手牌
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- Cost检测第一步：检查场上是否存在除本卡外至少1张表侧表示卡作为破坏对象
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler())
		-- Cost检测第二步：确认自己手牌中存在至少1张可丢弃的手牌
		and Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	-- 计算场上除本卡外所有可被选择为破坏对象的表侧表示卡数量作为最大丢弃限制
	local rt=Duel.GetTargetCount(Card.IsFaceup,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,e:GetHandler())
	-- 让玩家选择并丢弃1张到最大限制数量的手手牌，并记录丢弃数量作为所要选择的破坏对象数
	local ct=Duel.DiscardHand(tp,Card.IsDiscardable,1,rt,REASON_COST+REASON_DISCARD,nil)
	e:SetLabel(ct)
end
-- 定义效果①发动的对象选择与操作信息注册函数
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsFaceup() and chkc~=e:GetHandler() end
	-- 在效果发动前确认场上存在可选择的表侧表示卡
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler())
		and e:IsCostChecked() end
	local ct=e:GetLabel()
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择与丢弃手牌相同数量的表侧表示卡作为破坏对象
	local g=Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,ct,ct,e:GetHandler())
	-- 设置效果处理的操作信息为破坏所选的表侧表示卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,ct,0,0)
end
-- 定义效果①的破坏执行函数
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中成为效果对象的卡片组并过滤出其中依然能与连锁相对应的卡
	local rg=Duel.GetTargetsRelateToChain()
	if rg:GetCount()>0 then
		-- 将所有符合条件的被选择卡破坏
		Duel.Destroy(rg,REASON_EFFECT)
	end
end
-- 过滤满足解放条件的仪式·融合·同调·超量·灵摆·连接怪兽（须原本等级/阶级/连接大于0，且满足卡组·墓地存在可检索的怪兽）
function s.cfilter2(c,tp)
	return c:IsType(TYPE_RITUAL+TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ+TYPE_PENDULUM+TYPE_LINK)
		and s.lv_rk_lk(c)>0
		-- 检查卡组·墓地中是否存在可加入手牌的「道化一座」怪兽
		and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,c)
end
-- 获取卡片原本的等级、阶级或连接数
function s.lv_rk_lk(c)
	if c:GetOriginalLevel()>0 then
		return c:GetOriginalLevel()
	elseif c:GetOriginalRank()>0 then
		return c:GetOriginalRank()
	elseif c:GetLink()>0 then
		return c:GetLink()
	end
	return 0
end
-- 过滤可检索的且原本等级/阶级/连接与解放怪兽不同，且能加入手牌的「道化一座」怪兽
function s.thfilter(c,tc)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x1dc)
		and s.lv_rk_lk(c)>0 and s.lv_rk_lk(c)~=s.lv_rk_lk(tc)
		and c:IsAbleToHand()
end
-- 定义效果②发动的对象选择与花费Cost的解放处理函数
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if not e:IsCostChecked() then return false end
		-- 检查自己场上或手卡中是否存在满足条件的仪式·融合·同调·超量·灵摆·连接怪兽以供解放
		return Duel.CheckReleaseGroupEx(tp,s.cfilter2,1,REASON_COST,true,nil,tp)
	end
	-- 让玩家选择1只符合条件的自己场上或手卡中的仪式·融合·同调·超量·灵摆·连接怪兽
	local g=Duel.SelectReleaseGroupEx(tp,s.cfilter2,1,1,REASON_COST,true,nil,tp)
	e:SetLabelObject(g:GetFirst())
	-- 将选择的怪兽解放以作为发动效果的Cost
	Duel.Release(g,REASON_COST)
	-- 设置效果处理的操作信息为从卡组或墓地将1张怪兽卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
-- 定义效果②的检索执行函数
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从自己的卡组或墓地中选择1只符合条件的原本等级/阶级/连接与被解放怪兽不同的「道化一座」怪兽
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,tc)
	if g:GetCount()>0 then
		-- 将选择的怪兽加入玩家手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示加入手牌的卡片以供确认
		Duel.ConfirmCards(1-tp,g)
	end
end
