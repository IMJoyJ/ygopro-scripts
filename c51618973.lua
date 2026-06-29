--影霊衣の魔剣士 アバンス
-- 效果：
-- 这个卡名的③的效果在决斗中只能使用1次。
-- ①：这张卡召唤时才能发动。从卡组把「影灵衣魔剑士 阿旺斯」以外的1只「影灵衣」怪兽特殊召唤。
-- ②：「影灵衣」仪式怪兽1只仪式召唤的场合，可以由自己场上的这1张卡作为仪式召唤需要的数值的解放使用。
-- ③：这张卡被效果解放的场合才能发动。自己的除外状态的「影灵衣」卡任意数量加入手卡（同名卡最多1张）。
local s,id,o=GetID()
-- 注册召唤特召卡组影灵衣怪兽、单卡仪式解放、以及被效果解放时回收除外影灵衣卡的效果
function s.initial_effect(c)
	-- ①：这张卡召唤时才能发动。从卡组把「影灵衣魔剑士 阿旺斯」以外的1只「影灵衣」怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：1只「影灵衣」仪式怪兽仪式召唤的场合，可以由自己场上的这1张卡作为仪式召唤需要的数值的解放使用。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_RITUAL_LEVEL)
	e2:SetValue(s.rlevel)
	c:RegisterEffect(e2)
	-- ③：这张卡被效果解放的场合才能发动。自己的除外状态的「影灵衣」卡任意数量加入手卡（同名卡最多1张）。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"回收"
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_RELEASE)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,id+EFFECT_COUNT_CODE_DUEL)
	e3:SetCondition(s.thcon)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
end
-- 卡组中不为此卡名称、属于「影灵衣」字段且可被特殊召唤的怪兽的过滤条件
function s.spfilter(c,e,tp)
	return not c:IsCode(id) and c:IsSetCard(0xb4)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 召唤成功特召卡组怪兽效果的发动准备与合法性检查
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在可以特殊召唤的「影灵衣」怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置操作信息为从卡组特殊召唤怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 从卡组特殊召唤「影灵衣」怪兽的执行
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 确认自己场上是否有空闲怪兽格，若无则停止处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<1 then return end
	-- 向玩家提示选择需要从卡组特召的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组中选择1只符合条件的「影灵衣」怪兽
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽表侧表示特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 根据待仪式召唤的怪兽是否属于「影灵衣」提供特定的等级数值修改处理
function s.rlevel(e,c)
	local ec=e:GetHandler()
	-- 获取此卡原本所具有的怪兽星数
	local lv=aux.GetCappedLevel(ec)
	if not ec:IsLocation(LOCATION_MZONE) then return lv end
	if c:IsSetCard(0xb4) then
		local clv=c:GetLevel()
		return (lv<<16)+clv
	else return lv end
end
-- 确认此卡确实是因效果（而非规程或代币）而被释放送墓的
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return r&REASON_EFFECT~=0
end
-- 自己除外状态中属于「影灵衣」字段且可加入手牌的卡片的过滤条件
function s.thfilter(c)
	return c:IsFaceupEx() and c:IsSetCard(0xb4) and c:IsAbleToHand()
end
-- 回收除外「影灵衣」卡片效果的发动准备与合法性检查
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己除外状态是否存在符合回收条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_REMOVED,0,1,nil) end
	-- 设置操作信息为将卡片从除外状态加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_REMOVED)
end
-- 从除外状态将任意数量不同名「影灵衣」卡片加入手牌的执行
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己除外状态中所有表侧表示的「影灵衣」卡
	local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_REMOVED,0,nil)
	-- 向玩家提示选择需要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 为选择操作注册每一张所选卡片名称均不相同的过滤辅助规则
	aux.GCheckAdditional=aux.dncheck
	-- 从除外卡中选择任意数量不同名的卡
	local tg=g:SelectSubGroup(tp,aux.TRUE,false,1,g:GetCount())
	-- 重置并清除刚才临时注册的同名校验规则
	aux.GCheckAdditional=nil
	if tg and tg:GetCount()>0 then
		-- 将这些被选中的卡片送回持有者的手牌
		Duel.SendtoHand(tg,nil,REASON_EFFECT)
		-- 将加入手牌的卡片展示给对方玩家确认
		Duel.ConfirmCards(1-tp,tg)
	end
end
