--花札衛－萩に猪－
-- 效果：
-- 这张卡不能通常召唤。把「花札卫-萩间猪-」以外的自己场上1只「花札卫」怪兽解放的场合可以特殊召唤。
-- ①：这张卡特殊召唤成功的场合发动。自己从卡组抽1张，给双方确认。那是「花札卫」怪兽的场合，可以选对方场上1只怪兽破坏。不是的场合，那张卡送去墓地。
function c94388754.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。把「花札卫-萩间猪-」以外的自己场上1只「花札卫」怪兽解放的场合可以特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_HAND)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetCondition(c94388754.hspcon)
	e1:SetTarget(c94388754.hsptg)
	e1:SetOperation(c94388754.hspop)
	c:RegisterEffect(e1)
	-- ①：这张卡特殊召唤成功的场合发动。自己从卡组抽1张，给双方确认。那是「花札卫」怪兽的场合，可以选对方场上1只怪兽破坏。不是的场合，那张卡送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(94388754,0))  --"抽卡"
	e2:SetCategory(CATEGORY_DRAW+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetTarget(c94388754.target)
	e2:SetOperation(c94388754.operation)
	c:RegisterEffect(e2)
end
-- 过滤自己场上「花札卫-萩间猪-」以外的「花札卫」怪兽
function c94388754.hspfilter(c,tp)
	return c:IsSetCard(0xe6) and not c:IsCode(94388754)
		-- 检查将该卡解放后自己场上是否有可用的怪兽区域，且该卡由自己控制或是表侧表示
		and Duel.GetMZoneCount(tp,c)>0 and (c:IsControler(tp) or c:IsFaceup())
end
-- 特殊召唤规则的条件函数：检查自己场上是否存在可用于特殊召唤解放的怪兽
function c94388754.hspcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查玩家场上是否存在至少1张满足特殊召唤解放条件的卡
	return Duel.CheckReleaseGroupEx(tp,c94388754.hspfilter,1,REASON_SPSUMMON,false,nil,tp)
end
-- 特殊召唤规则的目标选择函数：选择要解放的怪兽并记录
function c94388754.hsptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取玩家场上可用于特殊召唤解放的卡片组，并过滤出满足条件的「花札卫」怪兽
	local g=Duel.GetReleaseGroup(tp,false,REASON_SPSUMMON):Filter(c94388754.hspfilter,nil,tp)
	-- 提示玩家选择要解放的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 特殊召唤规则的操作函数：解放选中的怪兽
function c94388754.hspop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 解放选中的怪兽以进行特殊召唤
	Duel.Release(g,REASON_SPSUMMON)
end
-- 效果①的发动准备：设置抽卡玩家、抽卡数量，并注册抽卡操作信息
function c94388754.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置当前连锁的效果处理对象玩家为自己
	Duel.SetTargetPlayer(tp)
	-- 设置当前连锁的效果处理参数为1（抽1张卡）
	Duel.SetTargetParam(1)
	-- 设置当前连锁的操作信息为：自己从卡组抽1张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 效果①的效果处理：自己抽1张卡并给双方确认，根据卡片种类决定破坏对方怪兽或送去墓地
function c94388754.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁设定的目标玩家和目标参数（抽卡玩家和抽卡张数）
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 执行抽卡，若成功抽到卡则继续处理
	if Duel.Draw(p,d,REASON_EFFECT)~=0 then
		-- 获取刚才因抽卡操作而加入手牌的那张卡
		local tc=Duel.GetOperatedGroup():GetFirst()
		-- 将抽到的卡给对方玩家确认
		Duel.ConfirmCards(1-tp,tc)
		if tc:IsType(TYPE_MONSTER) and tc:IsSetCard(0xe6) then
			-- 获取对方场上的所有怪兽
			local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
			-- 若对方场上有怪兽，则询问玩家是否选择其中1只破坏
			if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(94388754,1)) then  --"是否选对方场上1只怪兽破坏？"
				-- 中断当前效果，使后续的破坏处理与抽卡不视为同时进行
				Duel.BreakEffect()
				local sg=g:Select(tp,1,1,nil)
				-- 选中要破坏的怪兽并显示选择动画
				Duel.HintSelection(sg)
				-- 因效果破坏选中的对方怪兽
				Duel.Destroy(sg,REASON_EFFECT)
			end
		else
			-- 中断当前效果，使后续的送去墓地处理与抽卡不视为同时进行
			Duel.BreakEffect()
			-- 将抽到的非「花札卫」怪兽送去墓地
			Duel.SendtoGrave(tc,REASON_EFFECT)
		end
		-- 洗切自己的手牌
		Duel.ShuffleHand(tp)
	end
end
