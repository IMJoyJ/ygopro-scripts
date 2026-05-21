--白の枢機竜
-- 效果：
-- 「阿不思的落胤」＋自己墓地的卡名不同的怪兽×6
-- 这张卡用融合召唤才能从额外卡组特殊召唤。
-- ①：这张卡可以向对方怪兽全部各作1次攻击。
-- ②：这张卡的攻击宣言之际，自己必须把额外卡组1张卡送去墓地。
-- ③：1回合1次，融合召唤的这张卡在怪兽区域存在，需以「阿不思的落胤」为融合素材的融合怪兽在自己墓地有6种类以上存在的场合才能发动。双方的额外卡组的卡全部送去墓地。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数
function s.initial_effect(c)
	-- 记录该卡的效果中记载了「阿不思的落胤」的卡名
	aux.AddCodeList(c,68468459)
	-- 记录该卡将「阿不思的落胤」作为融合素材
	aux.AddMaterialCodeList(c,68468459)
	c:EnableReviveLimit()
	-- 「阿不思的落胤」＋自己墓地的卡名不同的怪兽×6
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_FUSION_MATERIAL)
	e0:SetCondition(s.Alba_System_Drugmata_Fusion_Condition())
	e0:SetOperation(s.Alba_System_Drugmata_Fusion_Operation())
	c:RegisterEffect(e0)
	-- 这张卡用融合召唤才能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetRange(LOCATION_EXTRA)
	e1:SetValue(s.splimit)
	c:RegisterEffect(e1)
	-- ①：这张卡可以向对方怪兽全部各作1次攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))  --"全部各作1次攻击"
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_ATTACK_ALL)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	-- ②：这张卡的攻击宣言之际，自己必须把额外卡组1张卡送去墓地。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"额外卡组1张送墓"
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_ATTACK_COST)
	e3:SetCost(s.atcost)
	e3:SetOperation(s.atop)
	c:RegisterEffect(e3)
	-- ③：1回合1次，融合召唤的这张卡在怪兽区域存在，需以「阿不思的落胤」为融合素材的融合怪兽在自己墓地有6种类以上存在的场合才能发动。双方的额外卡组的卡全部送去墓地。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))  --"双方额外全部送去墓地"
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1)
	e4:SetCondition(s.tgcon)
	e4:SetTarget(s.tgtg)
	e4:SetOperation(s.tgop)
	c:RegisterEffect(e4)
end
-- 限制特殊召唤方式只能是融合召唤
function s.splimit(e,se,sp,st)
	return bit.band(st,SUMMON_TYPE_FUSION)==SUMMON_TYPE_FUSION
end
-- 融合素材「阿不思的落胤」或其代替素材的过滤与合法性检查函数
function s.Alba_System_Drugmata_Fusion_Filter(c,mg,fc,tp,chkf,gc)
	if not c:IsFusionCode(68468459) and not c:IsHasEffect(EFFECT_FUSION_SUBSTITUTE) then return false end
	local g=mg:Filter(s.matfilter,c,tp)
	-- 设置卡片组检查条件为“卡名各不相同”
	aux.GCheckAdditional=aux.dncheck
	local res=g:CheckSubGroup(s.Alba_System_Drugmata_Fusion_Gcheck,6,6,fc,tp,c,chkf,gc)
	-- 重置卡片组检查条件
	aux.GCheckAdditional=nil
	return res
end
-- 过滤自己墓地中不具有特定不受融合素材效果影响的卡
function s.matfilter(c,tp)
	return c:IsLocation(LOCATION_GRAVE) and c:IsControler(tp) and not c:IsHasEffect(6205579)
end
-- 融合素材组合的合法性检查函数，包含调弦之魔术师检测、额外卡组出场位置检测及卡名不同检测
function s.Alba_System_Drugmata_Fusion_Gcheck(g,fc,tp,ec,chkf,gc)
	local sg=g:Clone()
	sg:AddCard(ec)
	-- 检查素材中是否存在受到「调弦之魔术师」等限制的怪兽
	if sg:IsExists(aux.TuneMagicianCheckX,1,nil,sg,EFFECT_TUNE_MAGICIAN_F) then return false end
	if gc and not sg:IsContains(gc) then return false end
	-- 检查是否存在其他附加的融合素材检查条件
	if aux.FCheckAdditional and not aux.FCheckAdditional(tp,sg,fc)
		-- 检查是否满足附加的融合素材达成目标检查条件，不满足则返回false
		or aux.FGoalCheckAdditional and not aux.FGoalCheckAdditional(tp,sg,fc) then return false end
	return g:GetClassCount(Card.GetFusionCode)==g:GetCount()
		-- 检查从额外卡组特殊召唤时是否有可用的怪兽区域
		and (chkf==PLAYER_NONE or Duel.GetLocationCountFromEx(tp,tp,sg,fc)>0)
end
-- 返回融合召唤条件的判定函数
function s.Alba_System_Drugmata_Fusion_Condition()
	return function(e,g,gc,chkf)
			-- 若未传入素材组，则检查是否存在必须作为融合素材的卡
			if g==nil then return aux.MustMaterialCheck(nil,e:GetHandlerPlayer(),EFFECT_MUST_BE_FMATERIAL) end
			local fc=e:GetHandler()
			local tp=e:GetHandlerPlayer()
			if gc then
				if not g:IsContains(gc) then return false end
				return g:IsExists(s.Alba_System_Drugmata_Fusion_Filter,1,nil,g,fc,tp,chkf,gc)
			end
			return g:IsExists(s.Alba_System_Drugmata_Fusion_Filter,1,nil,g,fc,tp,chkf,nil)
		end
end
-- 返回融合召唤时选择并确认融合素材的操作函数
function s.Alba_System_Drugmata_Fusion_Operation()
	return function(e,tp,eg,ep,ev,re,r,rp,gc,chkf)
			local fc=e:GetHandler()
			local tp=e:GetHandlerPlayer()
			local fg=eg:Clone()
			local g=nil
			local sg=nil
			while not sg do
				if g then
					fg:AddCard(g:GetFirst())
				end
				if gc then
					if s.Alba_System_Drugmata_Fusion_Filter(gc,fg,fc,tp,chkf) then
						g=Group.FromCards(gc)
						fg:RemoveCard(gc)
						local mg=fg:Filter(s.matfilter,fc,tp)
						-- 提示玩家选择融合素材
						Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FMATERIAL)  --"请选择要作为融合素材的卡"
						sg=mg:SelectSubGroup(tp,s.Alba_System_Drugmata_Fusion_Gcheck,false,6,6,fc,tp,g:GetFirst(),chkf,gc)
					else
						-- 提示玩家选择融合素材
						Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FMATERIAL)  --"请选择要作为融合素材的卡"
						g=fg:FilterSelect(tp,s.Alba_System_Drugmata_Fusion_Filter,1,1,nil,fg,fc,tp,chkf,gc)
						fg:Sub(g)
						local mg=fg:Filter(s.matfilter,fc,tp)
						-- 提示玩家选择融合素材
						Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FMATERIAL)  --"请选择要作为融合素材的卡"
						sg=mg:SelectSubGroup(tp,s.Alba_System_Drugmata_Fusion_Gcheck,true,6,6,fc,tp,g:GetFirst(),chkf,gc)
					end
				else
					-- 提示玩家选择融合素材
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FMATERIAL)  --"请选择要作为融合素材的卡"
					g=fg:FilterSelect(tp,s.Alba_System_Drugmata_Fusion_Filter,1,1,nil,fg,fc,tp,chkf,nil)
					fg:Sub(g)
					local mg=fg:Filter(s.matfilter,fc,tp)
					-- 设置卡片组检查条件为“卡名各不相同”
					aux.GCheckAdditional=aux.dncheck
					-- 提示玩家选择融合素材
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FMATERIAL)  --"请选择要作为融合素材的卡"
					sg=mg:SelectSubGroup(tp,s.Alba_System_Drugmata_Fusion_Gcheck,true,6,6,fc,tp,g:GetFirst(),chkf)
					-- 重置卡片组检查条件
					aux.GCheckAdditional=nil
				end
			end
			g:Merge(sg)
			-- 将选定的卡片组设置为融合素材
			Duel.SetFusionMaterial(g)
		end
end
-- 过滤可以作为代价送去墓地的卡
function s.costfilter(c)
	return c:IsAbleToGraveAsCost()
end
-- 攻击宣言代价的判定函数，检查自己额外卡组是否有卡可以送去墓地
function s.atcost(e,c,tp)
	-- 检查自己额外卡组是否存在至少1张可以送去墓地的卡
	return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_EXTRA,0,1,nil)
end
-- 攻击宣言代价的具体执行操作，将额外卡组的1张卡送去墓地
function s.atop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 玩家从自己额外卡组选择1张卡
	local cg=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_EXTRA,0,1,1,nil)
	-- 将选中的卡作为代价送去墓地
	Duel.SendtoGrave(cg,REASON_COST)
end
-- 过滤素材列表中记载了「阿不思的落胤」的融合怪兽
function s.cfilter(c)
	-- 检查该卡是否是以「阿不思的落胤」为融合素材的融合怪兽
	return aux.IsMaterialListCode(c,68468459)
end
-- 效果③的发动条件判定，需融合召唤的此卡在场，且自己墓地有6种类以上需以「阿不思的落胤」为素材的融合怪兽
function s.tgcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己墓地中所有需以「阿不思的落胤」为素材的融合怪兽
	local g=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_GRAVE,0,nil)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
		and g:GetClassCount(Card.GetCode)>5
end
-- 效果③的发动准备与效果分类注册
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查双方额外卡组是否存在可以送去墓地的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToGrave,tp,LOCATION_EXTRA,LOCATION_EXTRA,1,nil) end
	-- 获取双方额外卡组中所有可以送去墓地的卡
	local g=Duel.GetMatchingGroup(Card.IsAbleToGrave,tp,LOCATION_EXTRA,LOCATION_EXTRA,nil)
	-- 设置连锁处理的操作信息为将双方额外卡组的所有卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,g:GetCount(),0,0)
end
-- 效果③的效果处理，将双方额外卡组的卡全部送去墓地
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取双方额外卡组中所有可以送去墓地的卡
	local g=Duel.GetMatchingGroup(Card.IsAbleToGrave,tp,LOCATION_EXTRA,LOCATION_EXTRA,nil)
	-- 将获取到的双方额外卡组的卡全部送去墓地
	Duel.SendtoGrave(g,REASON_EFFECT)
end
