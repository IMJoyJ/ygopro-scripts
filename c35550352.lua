--Start for VS！
-- 效果：
-- 这个卡名的①②③的效果1回合各能使用1次。
-- ①：以自己场上1只「征服斗魂」怪兽为对象才能发动。和那只怪兽属性不同的1只「征服斗魂」怪兽从卡组加入手卡。
-- ②：自己场上的「征服斗魂」怪兽被战斗·效果破坏的场合，可以作为代替把手卡1只「征服斗魂」怪兽给人观看。
-- ③：自己结束阶段，自己场上有「征服斗魂」怪兽2只以上存在的场合才能发动。从卡组把1张「征服斗魂」陷阱卡在自己场上盖放。
local s,id,o=GetID()
-- 初始化效果注册：e1注册场地/永续魔法卡通用的发动空效果（ACTIVATE+自由时点），使卡片可以发动；e2注册①的检索效果，e3注册②的代替破坏效果，e4注册③的结束阶段盖放效果；e2/e3/e4分别以id、id+o、id+o*2作为CountLimit代码，实现这个卡名①②③的效果1回合各能使用1次。
function s.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 这个卡名的①②③的效果1回合各能使用1次。①：以自己场上1只「征服斗魂」怪兽为对象才能发动。和那只怪兽属性不同的1只「征服斗魂」怪兽从卡组加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))  --"检索"
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_FZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	-- 这个卡名的①②③的效果1回合各能使用1次。②：自己场上的「征服斗魂」怪兽被战斗·效果破坏的场合，可以作为代替把手卡1只「征服斗魂」怪兽给人观看。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_DESTROY_REPLACE)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCountLimit(1,id+o)
	e3:SetTarget(s.reptg)
	e3:SetValue(s.repval)
	e3:SetOperation(s.repop)
	c:RegisterEffect(e3)
	-- 这个卡名的①②③的效果1回合各能使用1次。③：自己结束阶段，自己场上有「征服斗魂」怪兽2只以上存在的场合才能发动。从卡组把1张「征服斗魂」陷阱卡在自己场上盖放。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))  --"盖放"
	e4:SetCategory(CATEGORY_SSET)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_PHASE+PHASE_END)
	e4:SetRange(LOCATION_FZONE)
	e4:SetCountLimit(1,id+o*2)
	e4:SetCondition(s.setcon)
	e4:SetTarget(s.settg)
	e4:SetOperation(s.setop)
	c:RegisterEffect(e4)
end
-- ①取对象时的对象筛选：对象必须是表侧表示的「征服斗魂」怪兽，并且卡组中必须有1只属性与之不同、可加入手卡的「征服斗魂」怪兽，否则不能选为对象。
function s.filter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0x195)
		-- 检查卡组中是否存在1张属性与对象怪兽不同且满足s.sfilter的「征服斗魂」怪兽，用于保证①的检索条件成立。
		and Duel.IsExistingMatchingCard(s.sfilter,tp,LOCATION_DECK,0,1,nil,c:GetAttribute())
end
-- ①的检索目标筛选：从卡组中检索的卡必须属于「征服斗魂」、是怪兽卡、属性与对象怪兽不同，并且可以被加入手卡。
function s.sfilter(c,attr)
	return not c:IsAttribute(attr) and c:IsSetCard(0x195)
		and c:IsAbleToHand() and c:IsType(TYPE_MONSTER)
end
-- ①的发动时点处理函数：先验证对象合法性（chkc分支和chk==0分支），然后提示玩家选择己方场上1只符合条件的「征服斗魂」怪兽作为对象，并声明后续将进行从卡组加入手卡的操作。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.filter(chkc,tp) end
	-- 合法发动检测：己方场上是否存在1只能够成为对象且通过s.filter筛选的「征服斗魂」怪兽。
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,0,1,nil,tp) end
	-- 发出选对象提示消息，显示文字“请选择效果的对象”，用于引导玩家选择对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 让发动玩家从己方场上选择1只满足s.filter的「征服斗魂」怪兽，并自动将其登记为当前连锁的对象。
	Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil,tp)
	-- 设置操作信息：声明本次连锁会产生把卡从卡组加入手卡的效果（CATEGORY_TOHAND），处理时从卡组选1张，供后续连锁判定使用。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ①的效果处理：取得对象，若对象仍与连锁相关且为表侧表示怪兽，则按其属性从卡组选择1只属性不同且满足条件的「征服斗魂」怪兽加入手卡，并向对方展示该卡。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取①发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() and tc:IsFaceup() and tc:IsType(TYPE_MONSTER) then
		local attr=tc:GetAttribute()
		-- 发出从卡组选择卡的提示，显示文字“请选择要加入手牌的卡”。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 从己方卡组选择1张属性与对象怪兽不同且满足s.sfilter的「征服斗魂」怪兽，作为加入手卡的卡。
		local g=Duel.SelectMatchingCard(tp,s.sfilter,tp,LOCATION_DECK,0,1,1,nil,attr)
		if g:GetCount()>0 then
			-- 将选择的「征服斗魂」怪兽加入其持有者的手卡（正常为发动者手卡），操作原因为效果。
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			-- 将被加入手卡的卡展示给对方玩家确认，完成检索的公开确认步骤。
			Duel.ConfirmCards(1-tp,g)
		end
	end
end
-- ②的代替破坏对象筛选：判断一只将被破坏的怪兽是否为表侧表示、位于己方怪兽区、属于「征服斗魂」且控制者为己方；破坏原因必须是战斗或效果，且不是已被其他代替破坏处理过的破坏。
function s.repfilter(c,tp)
	return c:IsFaceup() and c:IsLocation(LOCATION_MZONE) and c:IsSetCard(0x195) and c:IsControler(tp)
		and c:IsReason(REASON_BATTLE+REASON_EFFECT) and not c:IsReason(REASON_REPLACE)
end
-- ②的手牌代破素材筛选：选择1张手卡中的「征服斗魂」怪兽，要求它是怪兽卡且当前未公开（非公开状态才能给人观看）。
function s.spcostfilter(c)
	return c:IsSetCard(0x195) and c:IsType(TYPE_MONSTER) and not c:IsPublic()
end
-- ②的发动判定：先确认本次破坏事件中有满足s.repfilter的己方「征服斗魂」怪兽，同时手卡有符合s.spcostfilter的可展示「征服斗魂」怪兽；合法后询问玩家是否适用代替破坏。
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return eg:IsExists(s.repfilter,1,nil,tp)
		-- 在判定条件中追加：手卡中存在1张可以展示的「征服斗魂」怪兽，满足代替破坏所需代价。
		and Duel.IsExistingMatchingCard(s.spcostfilter,tp,LOCATION_HAND,0,1,c) end
	-- 弹出yes/no选择框，让玩家决定是否发动②的代替破坏效果（展示手卡怪兽代替破坏）。
	return Duel.SelectEffectYesNo(tp,e:GetHandler(),96)
end
-- 作为EFFECT_DESTROY_REPLACE的Value函数：对每只将被破坏的卡，用效果持有者的玩家身份调用s.repfilter，决定该卡是否适用本次代替破坏。
function s.repval(e,c)
	return s.repfilter(c,e:GetHandlerPlayer())
end
-- ②的代替破坏处理：从手卡选择1张「征服斗魂」怪兽展示给对方，然后洗切手卡，完成代替破坏的展示代价。
function s.repop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 发出选择手卡卡片提示，显示文字“请选择给对方确认的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 从手卡中选择1张满足s.spcostfilter的「征服斗魂」怪兽，作为代替破坏时给对方确认的卡。
	local g=Duel.SelectMatchingCard(tp,s.spcostfilter,tp,LOCATION_HAND,0,1,1,c)
	-- 将选择的「征服斗魂」怪兽展示给对方，实现给人观看。
	Duel.ConfirmCards(1-tp,g)
	-- 展示后洗切手卡，防止对方依据手卡位置记忆获得额外信息。
	Duel.ShuffleHand(tp)
end
-- ③条件计数用筛选：统计场上表侧表示且属于「征服斗魂」的怪兽。
function s.onfilter(c)
	return c:IsSetCard(0x195) and c:IsFaceup()
end
-- ③的发动条件：当前必须是自己回合的结束阶段，且己方场上有2只以上表侧表示的「征服斗魂」怪兽。
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	-- 统计己方怪兽区中表侧表示且属于「征服斗魂」的怪兽数量。
	local ct=Duel.GetMatchingGroupCount(s.onfilter,tp,LOCATION_MZONE,0,nil)
	-- 返回是否满足“自己的结束阶段”以及“自己场上有「征服斗魂」怪兽2只以上”两个条件。
	return Duel.GetTurnPlayer()==tp and ct>=2
end
-- ③要盖放的卡的筛选：卡组中的「征服斗魂」陷阱卡，且当前能够盖放到魔法与陷阱区。
function s.setfilter(c)
	return c:IsSetCard(0x195) and c:IsType(TYPE_TRAP) and c:IsSSetable()
end
-- ③的发动检查：只需确认卡组中是否存在1张可盖放的「征服斗魂」陷阱卡即可发动；实际选卡留到效果处理时进行。
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 合法性检查：卡组中是否存在1张满足s.setfilter的「征服斗魂」陷阱卡。
	if chk==0 then return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil) end
end
-- ③的效果处理：从卡组选择1张「征服斗魂」陷阱卡，里侧表示盖放到自己场上，不向对方展示。
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 发出选择卡组卡片提示，显示文字“请选择要盖放的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 从卡组选择1张满足s.setfilter的「征服斗魂」陷阱卡，作为要盖放的卡。
	local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的「征服斗魂」陷阱卡以里侧表示盖放到自己的魔法与陷阱区。
		Duel.SSet(tp,g)
	end
end
