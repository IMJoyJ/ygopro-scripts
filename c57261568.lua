--花札衛－牡丹に蝶－
-- 效果：
-- 这张卡不能通常召唤。把「花札卫-牡丹上蝴蝶-」以外的自己场上1只「花札卫」怪兽解放的场合可以特殊召唤。
-- ①：这张卡特殊召唤成功的场合发动。自己从卡组抽1张，给双方确认。那是「花札卫」怪兽的场合，从对方卡组上面把3张卡确认，用喜欢的顺序回到卡组上面或下面。不是的场合，那张卡送去墓地。
-- ②：把场上的这张卡作为同调素材的场合，可以把包含这张卡的全部同调素材怪兽当作2星怪兽使用。
function c57261568.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。把「花札卫-牡丹上蝴蝶-」以外的自己场上1只「花札卫」怪兽解放的场合可以特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_HAND)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetCondition(c57261568.hspcon)
	e1:SetTarget(c57261568.hsptg)
	e1:SetOperation(c57261568.hspop)
	c:RegisterEffect(e1)
	-- ①：这张卡特殊召唤成功的场合发动。自己从卡组抽1张，给双方确认。那是「花札卫」怪兽的场合，从对方卡组上面把3张卡确认，用喜欢的顺序回到卡组上面或下面。不是的场合，那张卡送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(57261568,0))  --"抽卡"
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetTarget(c57261568.target)
	e2:SetOperation(c57261568.operation)
	c:RegisterEffect(e2)
	-- ②：把场上的这张卡作为同调素材的场合，可以把包含这张卡的全部同调素材怪兽当作2星怪兽使用。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_SYNCHRO_MATERIAL_CUSTOM)
	e3:SetTarget(c57261568.syntg)
	e3:SetValue(1)
	e3:SetOperation(c57261568.synop)
	c:RegisterEffect(e3)
	-- ②：把场上的这张卡作为同调素材的场合，可以把包含这张卡的全部同调素材怪兽当作2星怪兽使用。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetCode(89818984)
	e4:SetRange(LOCATION_MZONE)
	c:RegisterEffect(e4)
end
-- 过滤自身以外的自己场上的「花札卫」怪兽作为特殊召唤的解放素材
function c57261568.hspfilter(c,tp)
	return c:IsSetCard(0xe6) and not c:IsCode(57261568)
		-- 检查解放该怪兽后是否有可用的怪兽区域，且该怪兽必须由自己控制或是表侧表示
		and Duel.GetMZoneCount(tp,c)>0 and (c:IsControler(tp) or c:IsFaceup())
end
-- 特殊召唤规则的条件：检查场上是否存在可解放的怪兽
function c57261568.hspcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查自己场上是否存在至少1只满足过滤条件的、可用于特殊召唤解放的怪兽
	return Duel.CheckReleaseGroupEx(tp,c57261568.hspfilter,1,REASON_SPSUMMON,false,nil,tp)
end
-- 特殊召唤规则的步骤：选择要解放的怪兽
function c57261568.hsptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取玩家场上可解放的卡片组，并过滤出符合条件的「花札卫」怪兽
	local g=Duel.GetReleaseGroup(tp,false,REASON_SPSUMMON):Filter(c57261568.hspfilter,nil,tp)
	-- 提示玩家选择要解放的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 特殊召唤规则的操作：解放选中的怪兽并特殊召唤
function c57261568.hspop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 解放选中的怪兽
	Duel.Release(g,REASON_SPSUMMON)
end
-- ①号效果的发动准备：设置抽卡操作信息
function c57261568.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置当前连锁的对象玩家为自己
	Duel.SetTargetPlayer(tp)
	-- 设置当前连锁的对象参数为1（抽1张卡）
	Duel.SetTargetParam(1)
	-- 设置连锁的操作信息为：玩家抽1张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- ①号效果的处理：抽卡并根据确认结果进行后续处理
function c57261568.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁设定的目标玩家和抽卡数量
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 执行抽卡，若成功抽卡则进行后续处理
	if Duel.Draw(p,d,REASON_EFFECT)~=0 then
		-- 获取刚才因抽卡操作加入手牌的卡片
		local tc=Duel.GetOperatedGroup():GetFirst()
		-- 将抽到的卡给对方玩家确认
		Duel.ConfirmCards(1-tp,tc)
		if tc:IsType(TYPE_MONSTER) and tc:IsSetCard(0xe6) then
			-- 计算对方卡组数量与3的较小值，确定需要确认的卡片数量
			local ct=math.min(3,Duel.GetFieldGroupCount(1-tp,LOCATION_DECK,0))
			if ct==0 then return end
			-- 中断当前效果处理，使后续操作与抽卡不视为同时进行
			Duel.BreakEffect()
			-- 获取对方卡组最上方的指定数量的卡片
			local g=Duel.GetDecktopGroup(1-tp,ct)
			-- 将对方卡组最上方的卡片给己方确认
			Duel.ConfirmCards(tp,g)
			-- 让己方玩家选择将卡片放回卡组最上面还是最下面
			local opt=Duel.SelectOption(tp,aux.Stringid(57261568,1),aux.Stringid(57261568,2))  --"回到卡组上面/回到卡组下面"
			-- 让己方玩家对对方卡组最上方的卡片进行排序
			Duel.SortDecktop(tp,1-tp,ct)
			if opt==1 then
				for i=1,ct do
					-- 获取对方卡组最上方的一张卡
					local mg=Duel.GetDecktopGroup(1-tp,1)
					-- 将该卡片移动到对方卡组最下方
					Duel.MoveSequence(mg:GetFirst(),SEQ_DECKBOTTOM)
				end
			end
		else
			-- 中断当前效果处理，使后续送去墓地的操作与抽卡不视为同时进行
			Duel.BreakEffect()
			-- 将抽到的非「花札卫」怪兽送去墓地
			Duel.SendtoGrave(tc,REASON_EFFECT)
		end
		-- 洗切己方手牌
		Duel.ShuffleHand(tp)
	end
end
-- 辅助函数：返回「花札卫」怪兽作为同调素材时的替代等级（2星）
function c57261568.cardiansynlevel(c)
	return 2
end
-- 过滤可作为同调素材的怪兽
function c57261568.synfilter(c,syncard,tuner,f)
	return c:IsFaceupEx() and c:IsCanBeSynchroMaterial(syncard,tuner) and (f==nil or f(c,syncard))
end
-- 递归检查所选的卡片组合是否能满足同调召唤的等级和数量要求
function c57261568.syncheck(c,g,mg,tp,lv,syncard,minc,maxc)
	g:AddCard(c)
	local ct=g:GetCount()
	local res=c57261568.syngoal(g,tp,lv,syncard,minc,ct)
		or (ct<maxc and mg:IsExists(c57261568.syncheck,1,g,g,mg,tp,lv,syncard,minc,maxc))
	g:RemoveCard(c)
	return res
end
-- 检查当前选中的素材组合是否符合同调召唤的条件（包括正常等级或全部当作2星）
function c57261568.syngoal(g,tp,lv,syncard,minc,ct)
	-- 检查素材数量是否达到最小值，且额外卡组怪兽出场区域是否足够
	return ct>=minc and Duel.GetLocationCountFromEx(tp,tp,g,syncard)>0
		and (g:CheckWithSumEqual(Card.GetSynchroLevel,lv,ct,ct,syncard)
			or g:CheckWithSumEqual(c57261568.cardiansynlevel,lv,ct,ct,syncard))
		-- 检查是否满足必须成为同调素材的卡片限制
		and aux.MustMaterialCheck(g,tp,EFFECT_MUST_BE_SMATERIAL)
end
-- 自定义同调素材效果的Target函数：检查是否存在合法的同调素材组合
function c57261568.syntg(e,syncard,f,min,max)
	local minc=min+1
	local maxc=max+1
	local c=e:GetHandler()
	local tp=syncard:GetControler()
	local lv=syncard:GetLevel()
	if lv<=c:GetLevel() and lv<=c57261568.cardiansynlevel(c) then return false end
	local g=Group.FromCards(c)
	-- 获取场上可用于该同调怪兽的素材，并过滤掉自身
	local mg=Duel.GetSynchroMaterial(tp):Filter(c57261568.synfilter,c,syncard,c,f)
	return mg:IsExists(c57261568.syncheck,1,g,g,mg,tp,lv,syncard,minc,maxc)
end
-- 自定义同调素材效果的Operation函数：让玩家选择同调素材并进行同调召唤
function c57261568.synop(e,tp,eg,ep,ev,re,r,rp,syncard,f,min,max)
	local minc=min+1
	local maxc=max+1
	local c=e:GetHandler()
	local lv=syncard:GetLevel()
	local g=Group.FromCards(c)
	-- 获取场上可用于该同调怪兽的素材，并过滤掉自身
	local mg=Duel.GetSynchroMaterial(tp):Filter(c57261568.synfilter,c,syncard,c,f)
	for i=1,maxc do
		local cg=mg:Filter(c57261568.syncheck,g,g,mg,tp,lv,syncard,minc,maxc)
		if cg:GetCount()==0 then break end
		local minct=1
		if c57261568.syngoal(g,tp,lv,syncard,minc,i) then
			minct=0
		end
		-- 提示玩家选择要作为同调素材的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SMATERIAL)  --"请选择要作为同调素材的卡"
		local sg=cg:Select(tp,minct,1,nil)
		if sg:GetCount()==0 then break end
		g:Merge(sg)
	end
	-- 将选中的卡片组设置为本次同调召唤的素材
	Duel.SetSynchroMaterial(g)
end
