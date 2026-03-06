--流星極輝巧群
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：「龙辉巧」卡被除外的场合，把自己场上1只「龙辉巧」怪兽解放，以自己的除外状态的最多2张「龙辉巧」卡为对象才能发动。那些卡加入手卡。
-- ②：把手卡1张「流星辉巧群」给对方观看才能发动。攻击力合计直到变成仪式召唤的怪兽的攻击力以上为止，把自己的手卡·场上的机械族怪兽解放，从自己的手卡·墓地把1只机械族仪式怪兽仪式召唤。
local s,id,o=GetID()
-- 初始化卡片效果，注册场地魔法卡的发动条件和两个效果
function s.initial_effect(c)
	-- 记录该卡拥有「龙辉巧」卡名
	aux.AddCodeList(c,22398665)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	-- ①：「龙辉巧」卡被除外的场合，把自己场上1只「龙辉巧」怪兽解放，以自己的除外状态的最多2张「龙辉巧」卡为对象才能发动。那些卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"回收除外"
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_REMOVE)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCountLimit(1,id)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCondition(s.thcon)
	e1:SetCost(s.thcost)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	-- ②：把手卡1张「流星辉巧群」给对方观看才能发动。攻击力合计直到变成仪式召唤的怪兽的攻击力以上为止，把自己的手卡·场上的机械族怪兽解放，从自己的手卡·墓地把1只机械族仪式怪兽仪式召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"墓地仪式"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetCost(s.spcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
-- 过滤器：判断是否为「龙辉巧」且表侧表示的怪兽
function s.cfilter(c)
	return c:IsSetCard(0x154) and c:IsFaceupEx()
end
-- 效果条件：除外的卡中存在「龙辉巧」怪兽
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil)
end
-- 过滤器：判断是否为「龙辉巧」怪兽
function s.rlfilter(c)
	return c:IsSetCard(0x154) and c:IsType(TYPE_MONSTER)
end
-- 效果费用：选择并解放1只「龙辉巧」怪兽
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否可以解放1只「龙辉巧」怪兽
	if chk==0 then return Duel.CheckReleaseGroup(tp,s.rlfilter,1,nil) end
	-- 选择1只「龙辉巧」怪兽进行解放
	local g=Duel.SelectReleaseGroup(tp,s.rlfilter,1,1,nil)
	-- 执行解放操作
	Duel.Release(g,REASON_COST)
end
-- 过滤器：判断是否为「龙辉巧」且可加入手牌的卡
function s.thfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x154) and c:IsAbleToHand()
end
-- 效果目标：选择1~2张除外的「龙辉巧」卡
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and s.thfilter(chkc) end
	-- 检查是否存在可选择的除外的「龙辉巧」卡
	if chk==0 then return Duel.IsExistingTarget(s.thfilter,tp,LOCATION_REMOVED,0,1,nil) end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择1~2张除外的「龙辉巧」卡
	local g=Duel.SelectTarget(tp,s.thfilter,tp,LOCATION_REMOVED,0,1,2,nil)
	-- 设置效果操作信息为将卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,g:GetCount(),0,0)
end
-- 效果处理：将目标卡加入手牌
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中设置的目标卡组
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local rg=tg:Filter(Card.IsRelateToEffect,nil,e)
	if rg:GetCount() then
		-- 将目标卡组送入手牌
		Duel.SendtoHand(rg,nil,REASON_EFFECT)
	end
end
-- 过滤器：判断是否为「流星辉巧群」且未公开的卡
function s.costfilter(c)
	return c:IsCode(22398665) and not c:IsPublic()
end
-- 效果费用：确认1张手牌中的「流星辉巧群」
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否存在手牌中的「流星辉巧群」
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 提示玩家选择要确认的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 选择1张手牌中的「流星辉巧群」
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_HAND,0,1,1,nil)
	-- 向对方确认选择的卡
	Duel.ConfirmCards(1-tp,g)
	-- 洗切自己的手牌
	Duel.ShuffleHand(tp)
end
-- 过滤器：判断是否为机械族
function s.rfilter(c)
	return c:IsRace(RACE_MACHINE)
end
-- 效果目标：检查是否存在可仪式召唤的机械族仪式怪兽
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 获取自己场上的机械族素材
		local mg=Duel.GetRitualMaterialEx(tp):Filter(Card.IsRace,nil,RACE_MACHINE)
		-- 检查是否存在满足条件的机械族仪式怪兽
		return Duel.IsExistingMatchingCard(s.RitualUltimateFilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,s.rfilter,e,tp,mg,nil,aux.GetCappedAttack,"Greater")
	end
	-- 设置效果操作信息为特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- 效果处理：特殊召唤机械族仪式怪兽
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	::cancel::
	-- 获取自己场上的机械族素材
	local mg=Duel.GetRitualMaterialEx(tp):Filter(Card.IsRace,nil,RACE_MACHINE)
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择1张满足条件的机械族仪式怪兽
	local tg=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.RitualUltimateFilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,s.rfilter,e,tp,mg,nil,aux.GetCappedAttack,"Greater")
	local tc=tg:GetFirst()
	if tc then
		mg=mg:Filter(Card.IsCanBeRitualMaterial,tc,tc)
		if tc.mat_filter then
			mg=mg:Filter(tc.mat_filter,tc,tp)
		else
			mg:RemoveCard(tc)
		end
		-- 提示玩家选择要解放的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
		-- 设置仪式召唤检查附加条件
		aux.GCheckAdditional=s.RitualCheckAdditional(tc,tc:GetAttack(),"Greater")
		local mat=mg:SelectSubGroup(tp,s.RitualCheck,true,1,#mg,tp,tc,tc:GetAttack(),"Greater")
		-- 清除仪式召唤检查附加条件
		aux.GCheckAdditional=nil
		if not mat then goto cancel end
		tc:SetMaterial(mat)
		-- 解放仪式召唤的素材
		Duel.ReleaseRitualMaterial(mat)
		-- 中断当前效果
		Duel.BreakEffect()
		-- 特殊召唤仪式怪兽
		Duel.SpecialSummon(tc,SUMMON_TYPE_RITUAL,tp,tp,false,true,POS_FACEUP)
		tc:CompleteProcedure()
	end
end
-- 判断素材总攻击力是否大于等于目标怪兽攻击力
function s.RitualCheckGreater(g,c,atk)
	if atk==0 then return false end
	-- 设置选中的卡为检查对象
	Duel.SetSelectedCard(g)
	-- 检查选中卡组的攻击力总和是否大于目标值
	return g:CheckWithSumGreater(aux.GetCappedAttack,atk)
end
-- 判断素材总攻击力是否等于目标怪兽攻击力
function s.RitualCheckEqual(g,c,atk)
	if atk==0 then return false end
	-- 检查选中卡组的攻击力总和是否等于目标值
	return g:CheckWithSumEqual(aux.GetCappedAttack,atk,#g,#g)
end
-- 判断是否满足仪式召唤条件
function s.RitualCheck(g,tp,c,atk,greater_or_equal)
	-- 检查是否有足够的怪兽区
	return s["RitualCheck"..greater_or_equal](g,c,atk) and Duel.GetMZoneCount(tp,g,tp)>0 and (not c.mat_group_check or c.mat_group_check(g,tp))
		-- 检查是否有附加条件
		and (not aux.RCheckAdditional or aux.RCheckAdditional(tp,g,c))
end
-- 生成仪式召唤附加条件函数
function s.RitualCheckAdditional(c,atk,greater_or_equal)
	if greater_or_equal=="Equal" then
		return  function(g)
					-- 检查选中卡组的攻击力总和是否小于等于目标值
					return (not aux.RGCheckAdditional or aux.RGCheckAdditional(g)) and g:GetSum(aux.GetCappedAttack)<=atk
				end
	else
		return  function(g,ec)
					if atk==0 then return #g<=1 end
					if ec then
						-- 检查选中卡组的攻击力总和减去目标卡攻击力是否小于等于目标值
						return (not aux.RGCheckAdditional or aux.RGCheckAdditional(g,ec)) and g:GetSum(aux.GetCappedAttack)-aux.GetCappedAttack(ec)<=atk
					else
						-- 检查是否有附加条件
						return not aux.RGCheckAdditional or aux.RGCheckAdditional(g)
					end
				end
	end
end
-- 判断是否满足仪式召唤最终条件
function s.RitualUltimateFilter(c,filter,e,tp,m1,m2,attack_function,greater_or_equal,chk)
	if bit.band(c:GetType(),0x81)~=0x81 or (filter and not filter(c,e,tp,chk)) or not c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_RITUAL,tp,false,true) then return false end
	local mg=m1:Filter(Card.IsCanBeRitualMaterial,c,c)
	if m2 then
		mg:Merge(m2)
	end
	if c.mat_filter then
		mg=mg:Filter(c.mat_filter,c,tp)
	else
		mg:RemoveCard(c)
	end
	local atk=attack_function(c)
	-- 设置仪式召唤检查附加条件
	aux.GCheckAdditional=s.RitualCheckAdditional(c,atk,greater_or_equal)
	local res=mg:CheckSubGroup(s.RitualCheck,1,#mg,tp,c,atk,greater_or_equal)
	-- 清除仪式召唤检查附加条件
	aux.GCheckAdditional=nil
	return res
end
