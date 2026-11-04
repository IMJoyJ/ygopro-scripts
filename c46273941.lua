--光帰葬魂の儀
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：1回合1次，可以发动。等级合计直到变成仪式召唤的怪兽的等级以上为止，把自己的手卡·卡组·场上（表侧表示）的通常怪兽卡送去墓地（同名卡最多1张），从自己的手卡·墓地把1只「塞尼特」仪式怪兽仪式召唤。那之后，可以让那只怪兽从自己墓地把1只通常怪兽当作装备魔法卡使用来装备。
-- ②：自己把衍生物以外的通常怪兽特殊召唤的场合才能发动。自己抽1张。
local s,id,o=GetID()
-- 初始化效果
function s.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：1回合1次，可以发动。等级合计直到变成仪式召唤的怪兽的等级以上为止，把自己的手卡·卡组·场上（表侧表示）的通常怪兽卡送去墓地（同名卡最多1张），从自己的手卡·墓地把1只「塞尼特」仪式怪兽仪式召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))  --"仪式召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	-- ②：自己把衍生物以外的通常怪兽特殊召唤的场合才能发动。自己抽1张。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"抽卡"
	e3:SetCategory(CATEGORY_DRAW)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_PLAYER_TARGET)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCountLimit(1,id)
	e3:SetCondition(s.drcon)
	e3:SetTarget(s.drtg)
	e3:SetOperation(s.drop)
	c:RegisterEffect(e3)
end
-- 获取通常怪兽或怪兽卡用于仪式的等级
function s.getrlv(c,rc)
	if c:IsType(TYPE_MONSTER) then
		return c:GetRitualLevel(rc)
	else
		return c:GetOriginalLevel()
	end
end
-- 检查仪式素材卡名不同且没有多余素材
function s.gcheckf(tc,lv)
	return function(sg,ec)
		-- 检查素材卡名是否互不相同
		if not aux.dncheck(sg) then return false end
		if ec then
			return sg:GetSum(s.getrlv,tc)-s.getrlv(ec,tc)<=lv
		else
			return true
		end
	end
end
-- 检查怪兽区空位及素材等级合计是否达到仪式怪兽等级以上
function s.RitualCheckGreater(g,c,lv,tp)
	-- 检查素材送墓后是否有可用怪兽区
	if Duel.GetMZoneCount(tp,g)<=0 then return false end
	-- 设置已选素材卡片
	Duel.SetSelectedCard(g)
	return g:CheckWithSumGreater(s.getrlv,lv,c)
end
-- 过滤手卡·墓地的「塞尼特」仪式怪兽
function s.spfilter(c,e,tp,m)
	if bit.band(c:GetType(),0x81)~=0x81 or not c:IsSetCard(0x1eb)
		or not c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_RITUAL,tp,false,true) then return false end
	if c.mat_filter then
		m=m:Filter(c.mat_filter,nil,tp)
	end
	local lv=c:GetLevel()
	-- 设置素材同名卡最多1张及等级上限的辅助检查
	aux.GCheckAdditional=s.gcheckf(c,lv)
	local res=m:CheckSubGroup(s.RitualCheckGreater,1,lv,c,lv,tp)
	-- 重置辅助检查函数
	aux.GCheckAdditional=nil
	return res
end
-- 过滤可作为仪式素材送去墓地的通常怪兽卡
function s.matfilter(c,e)
	return c:IsAllCardTypes(TYPE_NORMAL+TYPE_MONSTER)
		and c:IsFaceupEx() and c:IsAbleToGrave() and not c:IsImmuneToEffect(e)
end
-- 确认是否存在可仪式召唤的「塞尼特」仪式怪兽及可用素材
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 获取手卡·卡组·场上的通常怪兽卡
		local mg=Duel.GetMatchingGroup(s.matfilter,tp,LOCATION_DECK+LOCATION_HAND+LOCATION_ONFIELD,0,nil,e)
		-- 检查是否存在可仪式召唤的怪兽
		return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp,mg)
	end
	-- 设置操作信息：特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- 过滤墓地中可作为装备魔法装备的通常怪兽
function s.eqfilter(c,tp)
	return c:IsType(TYPE_NORMAL) and c:CheckUniqueOnField(tp) and not c:IsForbidden()
end
-- 仪式召唤「塞尼特」怪兽，并可选从墓地装备通常怪兽
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	::cancel::
	-- 获取手卡·卡组·场上的仪式素材怪兽卡
	local mg=Duel.GetMatchingGroup(s.matfilter,tp,LOCATION_DECK+LOCATION_HAND+LOCATION_ONFIELD,0,nil,e)
	-- 提示选择要仪式召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择手卡·墓地的1只「塞尼特」仪式怪兽
	local tg=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp,mg)
	if tg:GetCount()>0 then
		local tc=tg:GetFirst()
		if tc.mat_filter then
			mg=mg:Filter(tc.mat_filter,nil,tp)
		end
		local lv=tc:GetLevel()
		-- 提示选择送去墓地的仪式素材
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		-- 设置素材合法性检查
		aux.GCheckAdditional=s.gcheckf(tc,lv)
		local mat=mg:SelectSubGroup(tp,s.RitualCheckGreater,true,1,lv,tc,lv,tp)
		-- 重置辅助检查
		aux.GCheckAdditional=nil
		if not mat then goto cancel end
		tc:SetMaterial(mat)
		-- 将仪式素材送去墓地
		Duel.SendtoGrave(mat,REASON_EFFECT+REASON_MATERIAL+REASON_RITUAL)
		-- 中断效果处理
		Duel.BreakEffect()
		-- 仪式召唤选中的「塞尼特」怪兽
		Duel.SpecialSummon(tc,SUMMON_TYPE_RITUAL,tp,tp,false,true,POS_FACEUP)
		tc:CompleteProcedure()
		-- 检查魔陷区是否有空位
		if Duel.GetLocationCount(tp,LOCATION_SZONE)>0
			-- 检查墓地是否存在可装备的通常怪兽
			and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.eqfilter),tp,LOCATION_GRAVE,0,1,nil,tp)
			-- 由玩家选择是否装备
			and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否装备？"
			-- 提示选择要装备的怪兽
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
			-- 从墓地选择1只通常怪兽
			local ec=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.eqfilter),tp,LOCATION_GRAVE,0,1,1,nil,tp):GetFirst()
			if ec then
				-- 中断效果处理
				Duel.BreakEffect()
				-- 作为装备卡装备给该怪兽
				if not Duel.Equip(tp,ec,tc) then return end
				-- 那之后，可以让那只怪兽从自己墓地把1只通常怪兽当作装备魔法卡使用来装备。
				local e1=Effect.CreateEffect(e:GetHandler())
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_EQUIP_LIMIT)
				e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
				e1:SetLabelObject(tc)
				e1:SetValue(s.eqlimit)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD)
				ec:RegisterEffect(e1)
			end
		end
	end
end
-- 限制装备对象为仪式召唤的该怪兽
function s.eqlimit(e,c)
	return c==e:GetLabelObject()
end
-- 过滤自己特殊召唤的非衍生物通常怪兽
function s.cfilter(c,tp)
	return c:IsFaceup() and c:IsType(TYPE_NORMAL) and not c:IsType(TYPE_TOKEN) and c:GetSummonPlayer()==tp
end
-- 确认是否有自己特殊召唤的通常怪兽
function s.drcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp)
end
-- 抽卡效果目标确认
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否可以抽卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 设置目标玩家为自身
	Duel.SetTargetPlayer(tp)
	-- 设置抽卡数量为1
	Duel.SetTargetParam(1)
	-- 设置操作信息：抽1张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 抽卡效果处理
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取抽卡目标玩家与数量
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 抽1张卡
	Duel.Draw(p,d,REASON_EFFECT)
end
