--影霊衣の魔剣士 アバンス
-- 效果：
-- 这个卡名的③的效果在决斗中只能使用1次。
-- ①：这张卡召唤时才能发动。从卡组把「影灵衣魔剑士 阿旺斯」以外的1只「影灵衣」怪兽特殊召唤。
-- ②：「影灵衣」仪式怪兽1只仪式召唤的场合，可以由自己场上的这1张卡作为仪式召唤需要的数值的解放使用。
-- ③：这张卡被效果解放的场合才能发动。自己的除外状态的「影灵衣」卡任意数量加入手卡（同名卡最多1张）。
local s,id,o=GetID()
-- 初始化卡片效果：注册①召唤成功时从卡组特殊召唤「影灵衣」怪兽的诱发效果、②作为仪式召唤解放的永续效果、③被效果解放时回收除外卡加入手卡的诱发效果（决斗中只能使用1次）
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
	-- ②：「影灵衣」仪式怪兽1只仪式召唤的场合，可以由自己场上的这1张卡作为仪式召唤需要的数值的解放使用。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_RITUAL_LEVEL)
	e2:SetValue(s.rlevel)
	c:RegisterEffect(e2)
	-- 这个卡名的③的效果在决斗中只能使用1次。③：这张卡被效果解放的场合才能发动。自己的除外状态的「影灵衣」卡任意数量加入手卡（同名卡最多1张）。
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
-- 过滤函数：筛选卡组中不是「影灵衣魔剑士 阿旺斯」本身、属于「影灵衣」系列且可以被特殊召唤的怪兽
function s.spfilter(c,e,tp)
	return not c:IsCode(id) and c:IsSetCard(0xb4)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动条件检测：自己主要怪兽区有空位，且卡组存在至少1只可特殊召唤的符合条件的「影灵衣」怪兽
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测自己主要怪兽区是否有可用的空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检测卡组是否存在至少1只满足过滤条件（非同名且可以特殊召唤）的「影灵衣」怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置操作信息：宣告将从自己卡组特殊召唤1只怪兽（处理时才确定具体对象）
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：确认怪兽区仍有空位后，提示并从卡组选择1只符合条件的「影灵衣」怪兽，将其表侧表示特殊召唤到自己场上
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时再次确认自己主要怪兽区仍有空位，没有空位则中断处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<1 then return end
	-- 向玩家显示「请选择要特殊召唤的卡」的选择提示
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己卡组选择1只非同名、可特殊召唤的「影灵衣」怪兽
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 仪式祭品等级判定：作为仪式解放时，自身在场外只提供自身等级；在场上且仪式召唤对象是「影灵衣」仪式怪兽时，仅这1张卡即可作为仪式召唤需要的全部数值的解放（返回自身等级与仪式怪兽等级的组合值）
function s.rlevel(e,c)
	local ec=e:GetHandler()
	-- 获取这张卡的等级（限制在系统安全上限内）
	local lv=aux.GetCappedLevel(ec)
	if not ec:IsLocation(LOCATION_MZONE) then return lv end
	if c:IsSetCard(0xb4) then
		local clv=c:GetLevel()
		return (lv<<16)+clv
	else return lv end
end
-- 发动条件：这张卡是因效果被解放的场合才能发动
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return r&REASON_EFFECT~=0
end
-- 过滤函数：筛选自己除外状态的「影灵衣」卡中可以加入手卡的卡
function s.thfilter(c)
	return c:IsFaceupEx() and c:IsSetCard(0xb4) and c:IsAbleToHand()
end
-- 效果发动条件检测：自己除外状态存在至少1张可加入手卡的「影灵衣」卡，并设置操作信息宣告将把除外卡加入手卡
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测自己除外状态是否存在至少1张可加入手卡的「影灵衣」卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_REMOVED,0,1,nil) end
	-- 设置操作信息：宣告将从自己除外状态把1张以上的卡加入手卡（具体数量处理时确定）
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_REMOVED)
end
-- 效果处理：取得自己除外状态所有可加入手卡的「影灵衣」卡，让玩家从中选择任意数量且卡名互不相同的卡加入手卡，并向对方确认这些卡
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得自己除外状态所有满足条件的「影灵衣」卡
	local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_REMOVED,0,nil)
	-- 向玩家显示「请选择要加入手牌的卡」的选择提示
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 设置附加检查：选出的子组中的卡必须卡名互不相同（同名卡最多1张）
	aux.GCheckAdditional=aux.dncheck
	-- 让玩家从候选卡中选择1张至全部数量、卡名互不相同的卡组成子组
	local tg=g:SelectSubGroup(tp,aux.TRUE,false,1,g:GetCount())
	-- 清除附加的卡名不同检查，恢复默认状态
	aux.GCheckAdditional=nil
	if tg and tg:GetCount()>0 then
		-- 以效果原因将选出的卡加入持有者手卡
		Duel.SendtoHand(tg,nil,REASON_EFFECT)
		-- 向对方玩家公开确认加入手卡的这些卡
		Duel.ConfirmCards(1-tp,tg)
	end
end
