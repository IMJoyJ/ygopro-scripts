--空牙団の大義 フォルゴ
-- 效果：
-- 种族不同的怪兽3只
-- 这张卡不能作为连接素材。这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡连接召唤成功的场合才能发动。和那3只作为连接素材的怪兽不同种族的1只「空牙团」怪兽从卡组守备表示特殊召唤。
-- ②：对方场上的卡被战斗·效果破坏的场合才能发动。自己从卡组抽1张。自己场上的「空牙团」怪兽是3种类以上的场合，再让自己从卡组抽2张。
function c66023650.initial_effect(c)
	c:EnableReviveLimit()
	-- 设置连接召唤手续，需要3只怪兽作为素材，并使用lcheck函数过滤素材
	aux.AddLinkProcedure(c,nil,3,3,c66023650.lcheck)
	-- 这张卡不能作为连接素材。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	-- ①：这张卡连接召唤成功的场合才能发动。和那3只作为连接素材的怪兽不同种族的1只「空牙团」怪兽从卡组守备表示特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(66023650,0))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCountLimit(1,66023650)
	e2:SetCondition(c66023650.spcon)
	e2:SetTarget(c66023650.sptg)
	e2:SetOperation(c66023650.spop)
	c:RegisterEffect(e2)
	-- 和那3只作为连接素材的怪兽不同种族的1只「空牙团」怪兽从卡组守备表示特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_MATERIAL_CHECK)
	e3:SetValue(c66023650.valcheck)
	e3:SetLabelObject(e2)
	c:RegisterEffect(e3)
	-- ②：对方场上的卡被战斗·效果破坏的场合才能发动。自己从卡组抽1张。自己场上的「空牙团」怪兽是3种类以上的场合，再让自己从卡组抽2张。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(66023650,1))  --"抽卡"
	e4:SetCategory(CATEGORY_DRAW)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_DESTROYED)
	e4:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_PLAYER_TARGET)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,66023651)
	e4:SetCondition(c66023650.drcon)
	e4:SetTarget(c66023650.drtg)
	e4:SetOperation(c66023650.drop)
	c:RegisterEffect(e4)
end
-- 过滤函数：检查连接素材的种族是否各不相同
function c66023650.lcheck(g)
	return g:GetClassCount(Card.GetLinkRace)==g:GetCount()
end
-- 检查并记录连接召唤时所使用的素材怪兽的种族
function c66023650.valcheck(e,c)
	local g=c:GetMaterial()
	local val=0
	-- 遍历连接素材卡片组
	for tc in aux.Next(g) do
		val=bit.bor(val,tc:GetRace())
	end
	e:GetLabelObject():SetLabel(val)
end
-- 效果①的发动条件：这张卡是使用3只素材进行连接召唤成功
function c66023650.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK) and e:GetHandler():GetMaterialCount()==3
end
-- 效果①的特殊召唤过滤条件：卡组中与连接素材种族都不同的「空牙团」怪兽
function c66023650.spfilter(c,e,tp,rc)
	return c:IsSetCard(0x114) and not c:IsRace(rc) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 效果①的发动准备：检查怪兽区域空位以及卡组中是否存在可特殊召唤的怪兽，并设置特殊召唤的操作信息
function c66023650.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在满足过滤条件的「空牙团」怪兽
		and Duel.IsExistingMatchingCard(c66023650.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp,e:GetLabel()) end
	-- 设置特殊召唤的操作信息，表示将从卡组特殊召唤1张怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果①的效果处理：从卡组将1只满足条件的「空牙团」怪兽守备表示特殊召唤
function c66023650.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否仍有可用的怪兽区域空格，若无则结束处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从卡组选择1只满足过滤条件的「空牙团」怪兽
	local g=Duel.SelectMatchingCard(tp,c66023650.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,e:GetLabel())
	if g:GetCount()>0 then
		-- 将选中的怪兽以守备表示特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
-- 效果②的触发卡片过滤条件：原本在对方场上的卡被战斗或效果破坏
function c66023650.drcfilter(c,tp)
	return c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsPreviousControler(1-tp) and c:IsReason(REASON_BATTLE+REASON_EFFECT)
end
-- 效果②的发动条件：对方场上的卡被战斗·效果破坏
function c66023650.drcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c66023650.drcfilter,1,nil,tp)
end
-- 抽卡追加效果的过滤条件：自己场上表侧表示的「空牙团」怪兽
function c66023650.drfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x114)
end
-- 效果②的发动准备：计算可抽卡数量，检查玩家是否能抽卡，设置对象玩家和抽卡的操作信息
function c66023650.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取自己场上所有表侧表示的「空牙团」怪兽
	local g=Duel.GetMatchingGroup(c66023650.drfilter,tp,LOCATION_MZONE,0,nil)
	local ct=1
	if g:GetClassCount(Card.GetCode)>=3 then ct=3 end
	-- 检查玩家是否可以从卡组抽取指定数量的卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,ct) end
	-- 设置当前连锁的效果处理对象玩家为自己
	Duel.SetTargetPlayer(tp)
	-- 设置抽卡的操作信息，表示让指定玩家抽取对应数量的卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,ct)
end
-- 效果②的效果处理：自己从卡组抽1张，若自己场上的「空牙团」怪兽是3种类以上，则再抽2张
function c66023650.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上表侧表示的「空牙团」怪兽，用于后续判断种类数量
	local g=Duel.GetMatchingGroup(c66023650.drfilter,tp,LOCATION_MZONE,0,nil)
	-- 获取当前连锁中设定的目标玩家
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 抽1张卡成功，并判断自己场上的「空牙团」怪兽是否在3种类以上
	if Duel.Draw(p,1,REASON_EFFECT)>0 and g:GetClassCount(Card.GetCode)>=3 then
		-- 中断当前效果处理，使后续的抽卡处理与前一次抽卡不视为同时处理
		Duel.BreakEffect()
		-- 让目标玩家再从卡组抽2张卡
		Duel.Draw(p,2,REASON_EFFECT)
	end
end
